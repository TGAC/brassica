require 'rails_helper'

RSpec.describe "Submission management" do

  context "with no user signed in" do
    describe "GET /submissions" do
      it "redirects to submissions" do
        get "/submissions", {}, { 'HTTP_REFERER' => new_submission_path }
        expect(response).to redirect_to(new_submission_path)
      end
    end
  end

  context "with user signed in" do
    let(:user) { create :user }
    let(:plant_population) { create :plant_population, user: user }
    let(:country) { create :country }
    let(:trait_descriptor) { create :trait_descriptor, user: user }
    let!(:taxonomy_term) { create :taxonomy_term }
    let!(:population_type) { create :population_type }
    let!(:plant_line) { create :plant_line, user: user }

    before { login_as(user) }

    submission_types = {
      'population' => Submission::PlantPopulationFinalizer,
      'trial' => Submission::PlantTrialFinalizer
    }

    submission_types.each do |submission_type, finalizer_klass|
      context "with #{submission_type} submission" do
        describe "GET /submissions/:id" do
          let(:submission) { create :submission, :finalized, user: user, submission_type: submission_type }

          it "renders template" do
            get "/submissions/#{submission.id}"

            expect(response).to be_success
            expect(response).to render_template(:show)
          end
        end

        describe "POST /submissions" do
          it "creates submission of given type and redirects to edit" do
            post "/submissions", submission: { submission_type: submission_type }
            expect(response).to redirect_to(edit_submission_path(Submission.last))
          end
        end

        describe "GET /submissions/:id/edit" do
          let(:submission) { create :submission, user: user, submission_type: submission_type }

          it "renders template" do
            get "/submissions/#{submission.id}/edit"
            expect(response).to be_success
            expect(response).to render_template(:edit)
          end
        end

        describe "PUT /submissions/:id" do
          let(:update_params) {
            {
              'trial' => trial_update_params,
              'population' => population_update_params
            }.fetch(submission_type)
          }

          let(:trial_update_params) {
            {
              step01: {
                submission: {
                  content: {
                    plant_trial_name: "Trial A",
                    plant_trial_description: "Trial A brief description.",
                    project_descriptor: "Project A",
                    plant_population_id: plant_population.id.to_s,
                    trial_year: "1999",
                    institute_id: "InBadCzaM",
                    country_id: country.id.to_s,
                    trial_location_site_name: "X",
                    place_name: "Really well hidden place",
                    latitude: "55",
                    longitude: "12",
                    altitude: "-12",
                    terrain: "Heavenly pasture",
                    soil_type: "ST4",
                    statistical_factors: "XYZ",
                    data_status: 'plant_varieties'
                  }
                }
              },
              step02: {
                submission: {
                  content: {
                    trait_descriptor_list: [trait_descriptor.id.to_s]
                  }
                }
              },
              step03: {
                submission: {
                  content: {
                    lines_or_varieties: "plant_lines",
                    technical_replicate_numbers: ["1"],
                    design_factor_names: ["plot", "pot"]
                  }
                }
              },
              step04: {
                submission: {
                  content: {
                    upload_id: "666"
                  }
                }
              },
              step05: {
                submission: {
                  content: {
                    layout_upload_id: "667"
                  }
                }
              },
              step06: {
                submission: {
                  content: {
                    visibility: "private",
                    data_owned_by: "X",
                    data_provenance: "Y",
                    comments: "..."
                  }
                }
              }
            }
          }

          let(:population_update_params) {
            {
              step01: {
                submission: {
                  content: {
                    name: 'Population A'
                  }
                }
              },
              step02: {
                submission: {
                  content: {
                    taxonomy_term: taxonomy_term.name,
                    population_type: population_type.population_type
                  }
                }
              },
              step03: {
                submission: {
                  content: {
                    female_parent_line: plant_line.plant_line_name,
                    male_parent_line: plant_line.plant_line_name,
                    plant_line_list: [plant_line.id.to_s]
                  }
                }
              },
              step04: {
                submission: {
                  content: {
                    visibility: "private",
                    data_owned_by: "X",
                    data_provenance: "Y",
                    comments: "..."
                  }
                }
              }
            }
          }

          let(:submission) { create :submission, submission_type.to_sym, user: user, finalized: false }

          it "ignores submission type updates" do
            put "/submissions/#{submission.id}", submission: { submission_type: 'qtl', content: { foo: 'bar' } }
            expect(submission.reload.send("#{submission_type}?")).to be_truthy
          end

          it "ignores not-permitted params" do
            put "/submissions/#{submission.id}", submission: { content: { unknown_property: true } }
            expect(submission.reload.content.step01.unknown_property).to be nil
          end

          it "can be traversed from first to last step and finalized" do
            submission.steps.each do |step|
              step_params = update_params.fetch(step.to_sym)
              expected_redirect = if submission.reload.last_step?
                                    submission_path(submission)
                                  else
                                    edit_submission_path(submission)
                                  end

              put "/submissions/#{submission.id}", step_params
              expect(submission.reload.content.send(step).to_h).to include(step_params[:submission][:content])
              expect(response).to redirect_to(expected_redirect)
            end

            expect(submission).to be_finalized
          end

          context "with :step parameter" do
            before do
              submission.content.update(:step01, update_params.fetch(:step01))
              submission.step_forward
            end

            it "resets submission step if completed step was given" do
              expect { put "/submissions/#{submission.id}", step: 0 }.to \
                change { submission.reload.step }.from("step02").to("step01")

              expect(response).to redirect_to(edit_submission_path(submission))
            end

            it "does nothing if given step was not completed" do
              expect { put "/submissions/#{submission.id}", step: 2 }.not_to \
                change { submission.reload.step }.from("step02")

              expect(response).to redirect_to(edit_submission_path(submission))
            end
          end

          context "if last step" do
            let(:step_count) { submission.steps.count }
            before { (step_count - 1).times { submission.step_forward } }

            context "and cannot finalize" do
              before { allow_any_instance_of(finalizer_klass).to receive(:call).and_return(false) }

              it "redirects to first step with :validate option" do
                put "/submissions/#{submission.id}", submission: { content: { comments: "Lorem ipsum" } }
                expect(response).to redirect_to(edit_submission_path(submission, validate: true))
              end
            end
          end
        end
      end
    end
  end
end
