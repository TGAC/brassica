require 'rails_helper'

RSpec.describe TraitDescriptor do
  describe '#table_data' do
    it 'properly calculates associated trait score number' do
      td1 = create(:trait_descriptor, trait_scores: create_list(:trait_score, 3, plant_scoring_unit: nil))
      td2 = create(:trait_descriptor, trait_scores: create_list(:trait_score, 2, plant_scoring_unit: nil))
      table_data = TraitDescriptor.table_data
      expect(table_data.count).to eq 2
      expect(table_data.map{ |td| [td[2], td[5]] }).to match_array [
        [td1.descriptor_name, 3],
        [td2.descriptor_name, 2]
      ]
    end

    it 'orders trait by species name' do
      tss = create_list(:trait_score, 3)
      tss.each do |trait_score|
        create(:trait_descriptor, trait_scores: [trait_score])
      end
      ttns = tss.map{ |ts| ts.plant_scoring_unit.plant_trial.plant_population.taxonomy_term.name }
      table_data = TraitDescriptor.table_data
      expect(table_data.count).to eq 3
      expect(table_data.map(&:first)).to eq ttns.sort
    end

    it 'gets proper columns' do
      td = create(:trait_descriptor, trait_scores: [create(:trait_score)])
      table_data = TraitDescriptor.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0]).to eq [
        td.trait_scores[0].plant_scoring_unit.plant_trial.plant_population.taxonomy_term.name,
        td.trait_scores[0].plant_scoring_unit.plant_trial.plant_population.name,
        td.descriptor_name,
        td.trait_scores[0].plant_scoring_unit.plant_trial.project_descriptor,
        td.trait_scores[0].plant_scoring_unit.plant_trial.country.country_name,
        1
      ]
    end
  end
end
