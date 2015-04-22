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

    before { login_as(user) }

    describe "POST /submissions" do
      it "creates submission of given type and redirects to edit" do
        post "/submissions", submission: { submission_type: 'qtl' }
        expect(response).to redirect_to(edit_submission_path(Submission.last))
      end
    end

    describe "GET /submissions/:id/edit" do
      let(:submission) { create :submission, user: user }

      it "renders template" do
        get "/submissions/#{submission.id}/edit"
        expect(response).to be_success
        expect(response).to render_template(:edit)
      end
    end

    describe "PUT /submissions/:id" do
      let(:submission) { create :submission, user: user }

      it "updates submission with permitted params" do
        put "/submissions/#{submission.id}", submission: { content: { name: 'Population A' } }
        expect(submission.reload.content.step01.name).to eq('Population A')
      end

      it "ignores submission type updates" do
        put "/submissions/#{submission.id}",
          submission: { content: { name: 'Population A' }, submission_type: 'qtl' }
        expect(submission.reload.population?).to be_truthy
      end

      it "ignores not-permitted params" do
        put "/submissions/#{submission.id}", submission: { content: { unknown_property: true } }
        expect(submission.reload.content.step01.unknown_property).to be nil
      end

      context "unless last step" do
        it "advances submission step and redirects to edit" do
          put "/submissions/#{submission.id}", submission: { content: { name: 'Population B' } }
          expect(submission.reload.step).to eq("step02")
          expect(response).to redirect_to(edit_submission_path(submission))
        end
      end

      context "if last step" do
        before { 3.times { submission.step_forward } }
        before { allow_any_instance_of(Submission::PlantPopulationFinalizer).to receive(:call) }

        it "finalizes submission and redirects to show" do
          put "/submissions/#{submission.id}", submission: { content: { comments: "Lorem ipsum" } }
          expect(submission.reload).to be_finalized
          expect(response).to redirect_to(submission_path(submission))
        end
      end
    end

    describe "GET /submissions/:id" do
      let(:submission) { create :submission, :finalized, user: user }

      it "renders template" do
        get "/submissions/#{submission.id}"

        expect(response).to be_success
        expect(response).to render_template(:show)
      end
    end
  end

end
