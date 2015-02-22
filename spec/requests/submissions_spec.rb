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

    before {
      allow_any_instance_of(SubmissionsController).to receive(:current_user).and_return(user)
      allow_any_instance_of(SubmissionsController).to receive(:user_signed_in?).and_return(true)
    }

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
  end

end
