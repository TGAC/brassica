require 'rails_helper'

RSpec.describe TraitDescriptor do
  describe '#table_data' do
    it 'properly calculates associated trait score number' do
      pts = create_list(:plant_trial, 2)
      psu0 = create(:plant_scoring_unit, plant_trial: pts[0])
      psu1 = create(:plant_scoring_unit, plant_trial: pts[1])
      tses0 = create_list(:trait_score, 3, plant_scoring_unit: psu0, trait_descriptor: nil)
      tses1 = create_list(:trait_score, 2, plant_scoring_unit: psu1, trait_descriptor: nil)
      td1 = create(:trait_descriptor, trait_scores: [tses0[0], tses1[0], tses1[1]])
      td2 = create(:trait_descriptor, trait_scores: [tses0[1], tses0[2]])
      table_data = TraitDescriptor.table_data
      expect(table_data.count).to eq 3
      expect(table_data.map{ |td| [td[2], td[3], td[5]] }).to match_array [
        [td1.descriptor_name, pts[0].project_descriptor, '1'],
        [td1.descriptor_name, pts[1].project_descriptor, '2'],
        [td2.descriptor_name, pts[0].project_descriptor, '2']
      ]
    end

    it 'properly calculates associated qtl number' do
      pts = create_list(:plant_trial, 2)
      psu0 = create(:plant_scoring_unit, plant_trial: pts[0])
      psu1 = create(:plant_scoring_unit, plant_trial: pts[1])
      tses0 = create_list(:trait_score, 3, plant_scoring_unit: psu0, trait_descriptor: nil)
      tses1 = create_list(:trait_score, 2, plant_scoring_unit: psu1, trait_descriptor: nil)
      td1 = create(:trait_descriptor, trait_scores: [tses0[0], tses1[0], tses1[1]])
      td2 = create(:trait_descriptor, trait_scores: [tses0[1], tses0[2]])
      ptd1 = create_list(:processed_trait_dataset, 2, trait_descriptor: td1)
      ptd2 = create_list(:processed_trait_dataset, 3, trait_descriptor: td2)
      qtl1a = create_list(:qtl, 2, processed_trait_dataset: ptd1[0])
      qtl1b = create_list(:qtl, 2, processed_trait_dataset: ptd1[1])
      qtl2a = create_list(:qtl, 3, processed_trait_dataset: ptd2[0])
      qtl2b = create_list(:qtl, 3, processed_trait_dataset: ptd2[1])
      table_data = TraitDescriptor.table_data
      expect(table_data.count).to eq 3
      expect(table_data.map{ |td| [td[2], td[3], td[5], td[6]] }).to match_array [
        [td1.descriptor_name, pts[0].project_descriptor, '1', '4'],
        [td1.descriptor_name, pts[1].project_descriptor, '2', '4'],
        [td2.descriptor_name, pts[0].project_descriptor, '2', '6']
      ]
    end

    it 'orders trait by species name' do
      tss = create_list(:trait_score, 3)
      ttns = tss.map{ |ts| ts.plant_scoring_unit.plant_trial.plant_population.taxonomy_term.name }
      table_data = TraitDescriptor.table_data
      expect(table_data.count).to eq 3
      expect(table_data.map(&:first)).to eq ttns.sort
    end

    it 'gets proper columns' do
      td = create(:trait_score).trait_descriptor
      table_data = TraitDescriptor.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0]).to eq [
        td.trait_scores[0].plant_scoring_unit.plant_trial.plant_population.taxonomy_term.name,
        td.trait_scores[0].plant_scoring_unit.plant_trial.plant_population.name,
        td.descriptor_name,
        td.trait_scores[0].plant_scoring_unit.plant_trial.project_descriptor,
        td.trait_scores[0].plant_scoring_unit.plant_trial.country.country_name,
        '1',
        '0',
        td.id.to_s
      ]
    end
  end
end
