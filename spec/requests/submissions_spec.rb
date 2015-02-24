require 'rails_helper'

RSpec.describe "Submission management", type: :request do

  context "with no user signed in" do
    describe "GET /submissions" do
      it "redirects to root" do
        get "/submissions"
        expect(response).to redirect_to(root_path)
      end
    end
  end

  context "with user signed in" do
    let(:user) { create :user }

    before { login_as(user) }

    describe "POST /submissions" do
      it "creates default submission and redirects to edit" do
        post "/submissions"
        expect(response).to redirect_to(edit_submission_path(Submission.last))
      end
    end

    describe "GET /submissions/:id/edit" do
      let(:submission) { create :submission, user: user }

      it "renders view" do
        get "/submissions/#{submission.id}/edit"
        expect(response).to be_success
        expect(response).to render_template(:edit)
      end
    end

    describe "PUT /submissions/:id" do
      let(:submission) { create :submission, user: user }

      it "updates submission with permitted params" do
        put "/submissions/#{submission.id}", submission: { content: { name: 'Bardzo zielona kapusta' } }
        expect(submission.reload.content.step01.name).to eq('Bardzo zielona kapusta')
      end

      it "ignores not-permitted params" do
        put "/submissions/#{submission.id}", submission: { content: { kill_all_humans: true } }
        expect(submission.reload.content.step01.kill_all_humans).to be nil
      end

      context "unless last step" do
        it "advances submission step and redirects to edit" do
          put "/submissions/#{submission.id}", submission: { content: { name: 'Abrakadabra' } }
          expect(submission.reload.step).to eq("step02")
          expect(response).to redirect_to(edit_submission_path(submission))
        end
      end

      context "if last step" do
        before { 3.times { submission.step_forward } }

        it "finalizes submission and redirects to show" do
          put "/submissions/#{submission.id}", submission: { content: { comments: "Really good stuff, bro!" } }
          expect(submission.reload).to be_finalized
          expect(response).to redirect_to(submission_path(submission))
        end
      end
    end
  end

end
