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
        td.trait_scores[0].plant_scoring_unit.plant_trial.plant_population.id.to_s,
        td.trait_scores[0].plant_scoring_unit.plant_trial.id.to_s,
        td.id.to_s
      ]
    end

    it 'retrieves published data only' do
      u = create(:user)
      td = create(:trait_descriptor)

      pp1 = create(:plant_population, user: u, published: false)
      pp2 = create(:plant_population, user: u, published: false)

      pt1 = create(:plant_trial, user: u, plant_population: pp1, published: true)
      pt2 = create(:plant_trial, user: u, plant_population: pp2, published: false)
      pt3 = create(:plant_trial, user: u, plant_population: pp1, published: false)

      ptd1 = create(:processed_trait_dataset, plant_trial: pt1, trait_descriptor: td)
      ptd2 = create(:processed_trait_dataset, plant_trial: pt2, trait_descriptor: td)

      psu1 = create(:plant_scoring_unit, plant_trial: pt1, user: u, published: true)
      psu2 = create(:plant_scoring_unit, plant_trial: pt2, user: u, published: false)

      ts1 = create(:trait_score, plant_scoring_unit: psu1, trait_descriptor: td, user: u, published: true)
      ts2 = create(:trait_score, plant_scoring_unit: psu2, trait_descriptor: td, user: u, published: false)

      qtl1 = create(:qtl, processed_trait_dataset: ptd1, user: u, published: true)
      qtl2 = create(:qtl, processed_trait_dataset: ptd2, user: u, published: false)

      gd1 = TraitDescriptor.table_data

      # Expect a single record but with NULLs in place of unpublished plant population attributes
      expect(gd1.count).to eq 1
      expect(gd1.first[0]).to be_nil
      expect(gd1.first[1]).to be_nil
      expect(gd1.first[7]).to be_nil

      # Change plant population to published
      pp1.published = true
      pp1.save

      gd2 = TraitDescriptor.table_data

      # Expect the same record but this time with plant population details filled in
      expect(gd2.count).to eq 1
      expect(gd2.first[0]).to eq pp1.taxonomy_term.name
      expect(gd2.first[1]).to eq pp1.name
      for i in 2..6
        expect(gd2.first[i]).to eq gd1.first[i]
      end
      expect(gd2.first[7]).to eq pp1.id.to_s
      expect(gd2.first[8]).to eq gd1.first[8]
      expect(gd2.first[9]).to eq gd1.first[9]

      # Expect 2 records when u.id is supplied
      gd = TraitDescriptor.table_data(nil, u.id)
      expect(gd.count).to eq 2
    end
  end
end
