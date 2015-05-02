require 'rails_helper'

RSpec.describe TraitScore do
  describe '#filter' do
    it 'allow queries by trait_descriptor_id' do
      tss = create_list(:trait_score, 2)
      search = TraitScore.filter(
        query: {
          'trait_descriptor_id' => tss[0].trait_descriptor.id
        }
      )
      expect(search.count).to eq 1
      expect(search.first).to eq tss[0]
    end

    it 'allow queries by psu.plant_trial_id' do
      tss = create_list(:trait_score, 2)
      search = TraitScore.filter(
        query: {
          'plant_scoring_units.plant_trial_id' => tss[0].plant_scoring_unit.plant_trial.id
        }
      )
      expect(search.count).to eq 1
      expect(search.first).to eq tss[0]
    end
  end

  describe '#pluckable' do
    it 'gets proper data table columns' do
      ts = create(:trait_score)
      plucked = TraitScore.pluck_columns
      expect(plucked.count).to eq 1
      expect(plucked[0]).
        to eq [
          ts.score_value,
          ts.value_type,
          ts.scoring_date,
          ts.id
        ]
    end
  end
end
