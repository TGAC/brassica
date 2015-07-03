require 'rails_helper'

RSpec.describe "Submission uploads" do

  let(:submission) { create :submission }

  context "with no user signed in" do
    describe "POST /submissions/:submission_id/uploads" do
      it "does nothing" do
        post "/submissions/#{submission.id}/uploads"
        pending
        fail
      end
    end
  end

  context "with user signed in" do
    let(:user) { submission.user }

    before { login_as(user) }

    describe "POST /submissions/:submission_id/uploads" do
      let(:file) { Tempfile.new("upload") }

      it "creates upload" do
        post "/submissions/#{submission.id}/uploads", submission_upload: { file: file }

        binding.pry
      end
    end
  end
end
