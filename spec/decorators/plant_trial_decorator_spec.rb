require 'rails_helper'

RSpec.describe PlantTrialDecorator do
  let(:plant_trial) { create(:plant_trial) }
  let(:ptd) { plant_trial.decorate }
  let(:ps) { create(:plant_scoring_unit, plant_trial: plant_trial) }
  let(:tds) { create_list(:trait_descriptor, 2) }

  describe '#trait_headers' do
    it 'returns an empty array when no traits are scored' do
      expect(ptd.trait_headers).to eq []
    end

    it 'ignores technical replicate numbers when no present' do
      create(:trait_score, trait_descriptor: tds[0], plant_scoring_unit: ps)
      create(:trait_score, trait_descriptor: tds[1], plant_scoring_unit: ps)
      expect(ptd.trait_headers).to match_array tds.map(&:trait_name)
    end

    it 'provides technical replicate numbers where present' do
      create(:trait_score, trait_descriptor: tds[0], plant_scoring_unit: ps, technical_replicate_number: 2)
      create(:trait_score, trait_descriptor: tds[1], plant_scoring_unit: ps)
      expect(ptd.trait_headers).to match_array ["#{tds[0].trait_name} rep1", "#{tds[0].trait_name} rep2", tds[1].trait_name]
    end
  end
end
