require "rails_helper"

RSpec.describe Submission::TraitScoreTemplateGenerator do
  let(:plant_trial) { submission.submitted_object }
  let(:user) { submission.user }

  subject { described_class.new(submission) }

  context '.new' do
    it 'raises error when used for non-trial submission' do
      expect{ call(create(:submission, :population)) }.to raise_error ArgumentError
    end
  end
  
  context '#call' do
    let(:submission) { create(:submission, :trial) }

    it 'generates a simple trait scores template using plant lines as default' do
      trait_descriptor = create(:trait_descriptor)
      submission.content.update(:step02, trait_descriptor_list: [trait_descriptor.id.to_s])
      submission.save

      data = call(submission)

      expect(data.lines[0]).
        to eq "Plant scoring unit name,Plant accession,Originating organisation,Plant line,#{trait_descriptor.trait_name}\n"
      expect(data.lines[2]).
        to eq "Sample scoring unit B name - replace it,Accession identifier - replace it,Organisation name or acronym - replace it,Plant line name - replace it,Value of #{trait_descriptor.trait_name} scored for sample B - replace_it\n"
    end

    it 'generates template for plant varieties if asked for that' do
      submission.content.update(:step03, lines_or_varieties: 'plant_varieties')
      submission.save

      data = call(submission)

      expect(data.lines[0]).
        to eq "Plant scoring unit name,Plant accession,Originating organisation,Plant variety\n"
      expect(data.lines[2]).
        to eq "Sample scoring unit B name - replace it,Accession identifier - replace it,Organisation name or acronym - replace it,Plant variety name - replace it\n"
    end

    it 'does not break for no-traits submissions' do
      data = call(submission)

      expect(data.lines[0]).
        to eq "Plant scoring unit name,Plant accession,Originating organisation,Plant line\n"
    end

    it 'adds design factors to template, if defined' do
      submission.content.update(:step03, design_factor_names: ['polytunnel', 'rep', 'sub_block', 'pot_number'])
      submission.save

      data = call(submission)

      expect(data.lines[0]).
        to eq "Plant scoring unit name,polytunnel,rep,sub_block,pot_number,Plant accession,Originating organisation,Plant line\n"
      expect(data.lines[1]).
        to eq "Sample scoring unit A name - replace it,1,1,1,1,Accession identifier - replace it,Organisation name or acronym - replace it,Plant line name - replace it\n"
      expect(data.lines[2]).
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

      data = call(submission)

      expect(data.lines[0]).
        to eq "Plant scoring unit name,Plant accession,Originating organisation,Plant line,#{tds[0].trait_name} rep1,#{tds[0].trait_name} rep2,#{tds[1].trait_name},#{tds[2].trait_name}\n"
      expect(data.lines[1]).
        to eq "Sample scoring unit A name - replace it,Accession identifier - replace it,Organisation name or acronym - replace it,Plant line name - replace it,Value of #{tds[0].trait_name} rep1 scored for sample A - replace_it,Value of #{tds[0].trait_name} rep2 scored for sample A - replace_it,Value of #{tds[1].trait_name} scored for sample A - replace_it,Value of #{tds[2].trait_name} scored for sample A - replace_it\n"
      expect(data.lines[2]).
        to eq "Sample scoring unit B name - replace it,Accession identifier - replace it,Organisation name or acronym - replace it,Plant line name - replace it,Value of #{tds[0].trait_name} rep1 scored for sample B - replace_it,Value of #{tds[0].trait_name} rep2 scored for sample B - replace_it,Value of #{tds[1].trait_name} scored for sample B - replace_it,Value of #{tds[2].trait_name} scored for sample B - replace_it\n"
    end
  end

  def call(submission)
    Submission::TraitScoreTemplateGenerator.new(submission).call
  end
end
