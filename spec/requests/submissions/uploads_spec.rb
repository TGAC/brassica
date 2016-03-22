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
      it 'generates a simple trait scores template' do
        trait_descriptor = create(:trait_descriptor)
        submission.content.update(:step02,
                                  trait_descriptor_list: [trait_descriptor.id.to_s])
        submission.save

        get "/submissions/#{submission.id}/uploads/new"

        expect(response).to be_success
        expect(response.body.lines[0]).
          to eq "Plant scoring unit name\t#{trait_descriptor.descriptor_name}\n"
        expect(response.body.lines[2]).
          to eq "sample_scoring_unit_B_name__replace_it\tsample_B_value_0__replace_it\n"
      end

      it 'does not break for no-traits submissions' do
        get "/submissions/#{submission.id}/uploads/new"

        expect(response).to be_success
        expect(response.body.lines[0]).
          to eq "Plant scoring unit name\t\n"
      end
    end
  end
end
