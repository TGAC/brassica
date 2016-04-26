require "rails_helper"

RSpec.describe Submission::PlantTrialExporter do
  let(:submission) { create(:finalized_submission, :trial, publishable: true) }
  let(:plant_trial) { submission.submitted_object }
  # let(:plant_lines) { create_list(:plant_line, 2, plant_variety: create(:plant_variety)) }

  subject { described_class.new(submission) }

  describe "#documents" do
    it 'produces properly formatted all trial submission CSV documents' do
      psus = create_list(:plant_scoring_unit, 2, plant_trial: plant_trial)
      tds = create_list(:trait_descriptor, 2).sort_by(&:id)
      create(:trait_score, plant_scoring_unit: psus[0], trait_descriptor: tds[0])
      create(:trait_score, plant_scoring_unit: psus[1], trait_descriptor: tds[0])
      create(:trait_score, plant_scoring_unit: psus[1], trait_descriptor: tds[1])

      documents = subject.documents

      expect(documents.size).to eq 3
      expect(documents[:plant_trial].lines.size).to eq 2
      expect(documents[:plant_trial].lines[1].split(',')[0]).
        to eq plant_trial.plant_trial_name
      expect(documents[:plant_scoring_units].lines.size).to eq 3
      expect(documents[:plant_scoring_units].lines[1,2].map{ |l| l.split(',')[0] }).
        to match_array psus.map(&:scoring_unit_name)
      expect(documents[:trait_scoring].lines.size).to eq 3

      # NOTE: please note 'eq' - TD order matters
      expect(documents[:trait_scoring].lines[0].strip.split(',')).
        to eq (['Scoring unit name'] + tds.map(&:descriptor_name))

      expect(documents[:trait_scoring].lines[1,2].map{ |l| l.split(',')[0] }).
        to match_array psus.map(&:scoring_unit_name)
      expect(documents[:trait_scoring].lines[1,2].map{ |l| l.split(',')[1] }).
        to match_array tds[0].trait_scores.pluck(:score_value)
      expect(documents[:trait_scoring].lines[1,2].map{ |l| l.strip.split(',')[2] }).
        to match_array tds[1].trait_scores.pluck(:score_value) + ['-']
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
