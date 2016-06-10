require 'rails_helper'

RSpec.describe "Submission uploads" do

  let(:submission) { create(:submission, :trial) }

  context "with no user signed in" do
    describe "POST /submissions/:submission_id/uploads" do
      it "redirects for non-xhr request" do
        post "/submissions/#{submission.id}/uploads"
        expect(response).to redirect_to('/')
      end

      it "returns 401 for xhr request" do
        xhr :post, "/submissions/#{submission.id}/uploads"
        expect(response.status).to be 401
      end
    end
  end

  context "with user signed in" do
    let(:user) { submission.user }
    let(:parsed_response) { JSON.parse(response.body) }

    before { login_as(user) }

    describe "POST /submissions/:submission_id/uploads" do
      let(:file) { fixture_file_upload('files/score_upload.txt', 'text/plain') }

      it "creates upload" do
        expect {
          post "/submissions/#{submission.id}/uploads", submission_upload: {
            upload_type: 'trait_scores',
            file: file
          }
        }.to change { submission.uploads.count }.from(0).to(1)

        expect(response).to be_success
        expect(parsed_response).to include(
          "file_file_name" => "score_upload.txt",
          "delete_url" => submission_upload_path(submission, submission.uploads.last)
        )
      end
    end

    describe "GET /submissions/:submission_id/uploads/new" do
      it 'calls generator service with the submission as an argument' do
        expect_any_instance_of(Submission::TraitScoreTemplateGenerator).
          to receive(:call)

        get "/submissions/#{submission.id}/uploads/new"

        expect(response).to be_success
      end
    end
  end
end
