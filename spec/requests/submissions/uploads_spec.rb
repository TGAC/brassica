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
      it 'generates a simple trait scores template using plant lines as default' do
        trait_descriptor = create(:trait_descriptor)
        submission.content.update(:step02,
                                  trait_descriptor_list: [trait_descriptor.id.to_s])
        submission.save

        get "/submissions/#{submission.id}/uploads/new"

        expect(response).to be_success
        expect(response.body.lines[0]).
          to eq "Plant scoring unit name,Plant accession,Originating organisation,Plant line,#{trait_descriptor.trait_name}\n"
        expect(response.body.lines[2]).
          to eq "Sample scoring unit B name - replace it,Accession identifier - replace it,Organisation name or acronym - replace it,Plant line name - replace it,sample_B_value_for_#{trait_descriptor.trait_name}__replace_it\n"
      end

      it 'generates template for plant varieties if asked for that' do
        submission.content.update(:step03, lines_or_varieties: 'plant_varieties')
        submission.save

        get "/submissions/#{submission.id}/uploads/new"

        expect(response).to be_success
        expect(response.body.lines[0]).
          to eq "Plant scoring unit name,Plant accession,Originating organisation,Plant variety\n"
        expect(response.body.lines[2]).
          to eq "Sample scoring unit B name - replace it,Accession identifier - replace it,Organisation name or acronym - replace it,Plant variety name - replace it\n"
      end

      it 'does not break for no-traits submissions' do
        get "/submissions/#{submission.id}/uploads/new"

        expect(response).to be_success
        expect(response.body.lines[0]).
          to eq "Plant scoring unit name,Plant accession,Originating organisation,Plant line\n"
      end

      it 'adds design factors to template, if defined' do
        submission.content.update(:step03, design_factor_names: ['polytunnel', 'rep', 'sub_block', 'pot_number'])
        submission.save

        get "/submissions/#{submission.id}/uploads/new"

        expect(response).to be_success
        expect(response.body.lines[0]).
          to eq "Plant scoring unit name,polytunnel,rep,sub_block,pot_number,Plant accession,Originating organisation,Plant line\n"
        expect(response.body.lines[1]).
          to eq "Sample scoring unit A name - replace it,1,1,1,1,Accession identifier - replace it,Organisation name or acronym - replace it,Plant line name - replace it\n"
        expect(response.body.lines[2]).
          to eq "Sample scoring unit B name - replace it,1,1,1,2,Accession identifier - replace it,Organisation name or acronym - replace it,Plant line name - replace it\n"
      end

      it 'adds proper technical replicate columns if needed' do
        tds = create_list(:trait_descriptor, 3)
        submission.content.update(:step02, trait_descriptor_list: tds.map(&:id))
        submission.content.update(:step03,
          technical_replicate_numbers: {
            tds[0].trait_name => 2,
            tds[2].trait_name => 1
          }
        )
        submission.save

        get "/submissions/#{submission.id}/uploads/new"

        expect(response).to be_success
        expect(response.body.lines[0]).
          to eq "Plant scoring unit name,Plant accession,Originating organisation,Plant line,#{tds[0].trait_name}_rep1,#{tds[0].trait_name}_rep2,#{tds[1].trait_name},#{tds[2].trait_name}\n"
        expect(response.body.lines[1]).
          to eq "Sample scoring unit A name - replace it,Accession identifier - replace it,Organisation name or acronym - replace it,Plant line name - replace it,sample_A_value_for_#{tds[0].trait_name}_rep1__replace_it,sample_A_value_for_#{tds[0].trait_name}_rep2__replace_it,sample_A_value_for_#{tds[1].trait_name}__replace_it,sample_A_value_for_#{tds[2].trait_name}__replace_it\n"
        expect(response.body.lines[2]).
          to eq "Sample scoring unit B name - replace it,Accession identifier - replace it,Organisation name or acronym - replace it,Plant line name - replace it,sample_B_value_for_#{tds[0].trait_name}_rep1__replace_it,sample_B_value_for_#{tds[0].trait_name}_rep2__replace_it,sample_B_value_for_#{tds[1].trait_name}__replace_it,sample_B_value_for_#{tds[2].trait_name}__replace_it\n"
      end
    end
  end
end
