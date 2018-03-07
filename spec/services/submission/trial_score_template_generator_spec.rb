require "rails_helper"

RSpec.describe Submission::TraitScoreTemplateGenerator do
  let(:plant_trial) { submission.submitted_object }
  let(:user) { submission.user }

  subject { described_class.new(submission) }

  context '.new' do
    it 'raises error when used for non-trial submission' do
      expect{ call(build(:submission, :population)) }.to raise_error ArgumentError
    end
  end

  context '#call' do
    let(:submission) { build(:submission, :trial) }

    it 'generates a simple trait scores template using plant lines as default' do
      trait_descriptor = create(:trait_descriptor)
      submission.content.update(:step02, trait_descriptor_list: [trait_descriptor.id.to_s])

      data = call(submission)

      expect(data.row(1)).
        to eq ["Column", "Plant scoring unit name", "Plant accession", "Originating organisation", "Year produced",
               "Plant line", trait_descriptor.trait_name]

      expect(data.row(2)[0]).to eq("Description")

      expect(data.row(4)).
        to eq [nil, "Sample scoring unit B name - replace it", "Accession identifier - replace it",
               "Organisation name or acronym - replace it", "Year produced - replace it",
               "Plant line name - replace it",
               "Value of #{trait_descriptor.trait_name} scored for sample B - replace_it"]
    end

    it 'generates template for plant varieties if asked for that' do
      submission.content.update(:step03, lines_or_varieties: 'plant_varieties')

      data = call(submission)

      expect(data.row(1)).
        to eq ["Column", "Plant scoring unit name", "Plant accession", "Originating organisation", "Year produced",
               "Plant variety"]

      expect(data.row(4)).
        to eq [nil, "Sample scoring unit B name - replace it", "Accession identifier - replace it",
               "Organisation name or acronym - replace it", "Year produced - replace it",
               "Plant variety name - replace it"]
    end

    it 'does not break for no-traits submissions' do
      data = call(submission)

      expect(data.row(1)).
        to eq ["Column", "Plant scoring unit name", "Plant accession", "Originating organisation", "Year produced",
               "Plant line"]
    end

    it 'adds design factors to template, if defined' do
      submission.content.update(:step03, design_factor_names: ['polytunnel', 'rep', 'sub_block', 'pot_number'])

      data = call(submission)

      expect(data.row(1)).
        to eq ["Column", "Plant scoring unit name", "polytunnel", "rep", "sub_block", "pot_number",
               "Plant accession", "Originating organisation", "Year produced", "Plant line"]

      expect(data.row(3)).
        to eq [nil, "Sample scoring unit A name - replace it",
               "1 - replace it", "1 - replace it", "1 - replace it", "1 - replace it",
               "Accession identifier - replace it", "Organisation name or acronym - replace it",
               "Year produced - replace it", "Plant line name - replace it"]

      expect(data.row(4)).
        to eq [nil, "Sample scoring unit B name - replace it",
               "1 - replace it", "1 - replace it", "1 - replace it", "2 - replace it",
               "Accession identifier - replace it", "Organisation name or acronym - replace it",
               "Year produced - replace it", "Plant line name - replace it"]
    end

    it 'adds proper technical replicate columns if needed' do
      tds = create_list(:trait_descriptor, 3)
      submission.content.update(:step02, trait_descriptor_list: tds.map(&:id))
      submission.content.update(:step03, technical_replicate_numbers: [2, nil, 1])

      data = call(submission)

      expect(data.row(1)).
        to eq ["Column", "Plant scoring unit name", "Plant accession", "Originating organisation", "Year produced",
               "Plant line", "#{tds[0].trait_name} rep1", "#{tds[0].trait_name} rep2",
               tds[1].trait_name, tds[2].trait_name]

      expect(data.row(3)).
        to eq [nil, "Sample scoring unit A name - replace it", "Accession identifier - replace it",
               "Organisation name or acronym - replace it", "Year produced - replace it",
               "Plant line name - replace it",
               "Value of #{tds[0].trait_name} rep1 scored for sample A - replace_it",
               "Value of #{tds[0].trait_name} rep2 scored for sample A - replace_it",
               "Value of #{tds[1].trait_name} scored for sample A - replace_it",
               "Value of #{tds[2].trait_name} scored for sample A - replace_it"]

      expect(data.row(4)).
        to eq [nil, "Sample scoring unit B name - replace it", "Accession identifier - replace it",
               "Organisation name or acronym - replace it", "Year produced - replace it",
               "Plant line name - replace it",
               "Value of #{tds[0].trait_name} rep1 scored for sample B - replace_it",
               "Value of #{tds[0].trait_name} rep2 scored for sample B - replace_it",
               "Value of #{tds[1].trait_name} scored for sample B - replace_it",
               "Value of #{tds[2].trait_name} scored for sample B - replace_it"]
    end
  end

  def call(submission)
    xls = nil

    Submission::TraitScoreTemplateGenerator.new(submission).call do |file|
      xls = Roo::Excel.new(file)
      xls.default_sheet = "Trait scores"
    end

    xls
  end
end
