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

  describe '#table_data' do
    it 'retrieves published data only' do
      u = create(:user)
      ts1 = create(:trait_score, user: u, published: true)
      ts2 = create(:trait_score, user: u, published: false)

      tsd = TraitScore.table_data
      expect(tsd.count).to eq 1

      tsd = TraitScore.table_data(nil, u.id)
      expect(tsd.count).to eq 2
    end
  end
end
