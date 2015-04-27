require 'rails_helper'

RSpec.describe TraitScore do
  describe '#filter' do
    it 'allow queries by descriptor_name' do
      tss = create_list(:trait_score, 2)
      search = TraitScore.filter(
        query: {
          'trait_descriptors.descriptor_name' => tss[0].trait_descriptor.descriptor_name
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
          ts.plant_scoring_unit.scoring_unit_name,
          ts.plant_scoring_unit.id,
          ts.id
        ]
    end
  end
end
