require "rails_helper"

RSpec.describe Submission::PlantTrialExporter do
  let(:submission) { create(:finalized_submission, :trial, published: true) }
  let(:plant_trial) { submission.submitted_object }
  let(:plant_line) { create(:plant_line, plant_variety: create(:plant_variety)) }
  subject { described_class.new(submission) }

  describe "#documents" do
    it 'produces properly formatted all trial submission CSV documents' do
      psus = [
        create(:plant_scoring_unit,
               plant_trial: plant_trial,
               plant_accession: create(:plant_accession, plant_line: plant_line)),
        create(:plant_scoring_unit,
               plant_trial: plant_trial,
               plant_accession: create(:plant_accession, :with_variety)),
        create(:plant_scoring_unit,
               plant_trial: plant_trial,
               plant_accession: create(:plant_accession, plant_line: create(:plant_line)))
      ]
      tds = create_list(:trait_descriptor, 2).sort_by(&:id)
      ts1 = create(:trait_score, plant_scoring_unit: psus[0], trait_descriptor: tds[0])
      ts2 = create(:trait_score, plant_scoring_unit: psus[1], trait_descriptor: tds[0], technical_replicate_number: 2)
      ts3 = create(:trait_score, plant_scoring_unit: psus[1], trait_descriptor: tds[1])

      documents = subject.documents

      expect(documents.size).to eq 3
      expect(documents[:plant_trial].lines.size).to eq 2
      expect(documents[:plant_trial].lines[1].split(',')[0]).
        to eq plant_trial.plant_trial_name

      expect(documents[:trait_descriptors].lines.size).to eq 3
      expect(documents[:trait_descriptors].lines[1,2].map{ |l| l.split(',')[1] }).
        to match_array tds.map(&:trait_name)

      expect(documents[:trait_scoring].lines.size).to eq 4
      expect(documents[:trait_scoring].lines[0].strip.split(',')[13,3]).
        to eq ["#{tds[0].trait_name} rep1", "#{tds[0].trait_name} rep2", tds[1].trait_name]

      generated_scores = CSV.parse(documents[:trait_scoring]).map{ |row| row[13,3] }
      expect(documents[:trait_scoring].lines[1,3].map{ |l| l.split(',')[0] }).
        to match_array psus.map(&:scoring_unit_name)
      expect(generated_scores[0]).to eq [tds[0].trait.name + ' rep1', tds[0].trait.name + ' rep2', tds[1].trait.name]
      expect(generated_scores[1]).to eq [ts1.score_value, '-', '-']
      expect(generated_scores[2]).to eq ['-', ts2.score_value, ts3.score_value]
      expect(generated_scores[3]).to eq ['-', '-', '-']

      expect(documents[:trait_scoring].lines[1,3].map{ |l| l.split(',')[3] }).
        to match_array [
          psus[0].plant_accession.plant_line.plant_variety.plant_variety_name,
          psus[1].plant_accession.plant_variety.plant_variety_name,
          '' # A case of PA -> PL with no PV in PL
        ]
    end

    it 'produces no documents for no-data cases' do
      documents = subject.documents
      expect(documents.size).to eq 1
    end

    it 'handles commas appropriately' do
      plant_trial.update_attribute(:plant_trial_name, 'With,comma')
      documents = subject.documents
      expect(documents.size).to eq 1
      expect(documents[:plant_trial].lines.size).to eq 2
      expect(documents[:plant_trial].lines[1]).
        to include '"With,comma"'
    end
  end
end
