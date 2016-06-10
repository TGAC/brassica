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
            if submission.population?
              {
                submission: {
                  content: {
                    name: 'Population A'
                  }
                }
              }
            elsif submission.trial?
              {
                submission: {
                  content: {
                    plant_trial_name: "Trial A",
                    project_descriptor: "Project A",
                    trial_year: "1999",
                    plant_population_id: plant_population.id.to_s,
                    country_id: country.id.to_s,
                    place_name: "Really well hidden place",
                    data_status: 'plant_varieties'
                  }
                }
              }
            end
          }

          let(:submission) { create :submission, submission_type.to_sym, user: user, finalized: false }

          it "updates submission with permitted params" do
            put "/submissions/#{submission.id}", update_params
            expect(submission.reload.content.step01.to_h).to include(update_params[:submission][:content])
          end

          it "ignores submission type updates" do
            put "/submissions/#{submission.id}", update_params.merge(submission_type: 'qtl')
            expect(submission.reload.send("#{submission_type}?")).to be_truthy
          end

          it "ignores not-permitted params" do
            put "/submissions/#{submission.id}", submission: { content: { unknown_property: true } }
            expect(submission.reload.content.step01.unknown_property).to be nil
          end

          context "with :step parameter" do
            before do
              submission.content.update(:step01, update_params)
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

          context "unless last step" do
            it "advances submission step and redirects to edit" do
              put "/submissions/#{submission.id}", update_params
              expect(submission.reload.step).to eq("step02")
              expect(response).to redirect_to(edit_submission_path(submission))
            end
          end

          context "if last step" do
            let(:step_count) { submission.steps.count }
            before { (step_count - 1).times { submission.step_forward } }

            context "and can finalize" do
              before { allow_any_instance_of(finalizer_klass).to receive(:call).and_return(true) }

              it "finalizes submission and redirects to show" do
                put "/submissions/#{submission.id}", submission: { content: { comments: "Lorem ipsum" } }
                expect(response).to redirect_to(submission_path(submission))
              end
            end

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
