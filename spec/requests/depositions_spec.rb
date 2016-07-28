require 'rails_helper'

RSpec.describe "Depositions management" do
  context "with no user signed in" do
    describe "GET /depositions/new" do
      it "redirects to submissions" do
        get new_deposition_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  context "with user signed in" do
    let(:user) { create :user }

    before { login_as(user) }

    %w(population trial).each do |submission_type|
      context "when depositing #{submission_type} submission" do
        describe "POST /depositions" do
          let(:submission) { create :submission,
                                    :finalized,
                                    published: true,
                                    user: user,
                                    submission_type: submission_type }

          it "performs deposition and assigns a DOI" do
            VCR.use_cassette('zenodo') do
              post "/depositions", deposition: { submission_id: submission.id }
            end

            expect(response).to redirect_to submission_path(submission)
            expect(submission.reload.doi).not_to be_nil
            expect(flash[:notice]).
              to eq "Deposited data in Zenodo with DOI number:#{submission.doi}."
          end

          it "warns the user if something goes wrong" do
            allow_any_instance_of(ZenodoDepositor).
              to receive(:query_url).and_return('http://total.rubbish/')

            VCR.use_cassette('zenodo') do
              post "/depositions", deposition: { submission_id: submission.id }
            end

            expect(response).to redirect_to submission_path(submission)
            expect(submission.reload.doi).to be_nil
            expect(flash[:alert]).
              to eq 'Zenodo service responded with invalid content. Unable to conclude data deposition.'
          end
        end
      end
    end
  end
end
