require 'rails_helper'

RSpec.describe TraitDescriptor do
  context "validations" do
    it { should validate_presence_of(:trait_id) }
    it { should validate_presence_of(:scoring_method) }
    it { should validate_presence_of(:units_of_measurements) }
  end

  describe '#table_data' do
    it 'properly calculates associated trait score number' do
      td1 = create(:trait_descriptor)
      td2 = create(:trait_descriptor)
      create_list(:trait_score, 3, trait_descriptor: td1)
      create_list(:trait_score, 2, trait_descriptor: td2)
      table_data = TraitDescriptor.table_data
      expect(table_data.count).to eq 2
      expect(table_data.map{ |td| [td[1], td[6]] }).to match_array [
        [td1.trait_name, 3],
        [td2.trait_name, 2]
      ]
    end

    it 'properly returns associated trial ids' do
      tds = create_list(:trait_descriptor, 4)
      pts = create_list(:plant_trial, 2)
      tses = create_list(:trait_score, 2, trait_descriptor: tds[0], plant_scoring_unit: create(:plant_scoring_unit, plant_trial: pts[0]))
      create(:trait_score, trait_descriptor: tds[1], plant_scoring_unit: create(:plant_scoring_unit, plant_trial: pts[1]))
      create(:trait_score, trait_descriptor: tds[2], plant_scoring_unit: create(:plant_scoring_unit, plant_trial: pts[0]))
      table_data = TraitDescriptor.table_data
      expect(table_data.map{ |td| [td[9], td[10]] }).to match_array [
        [[pts[0].id], tds[0].id],
        [[pts[1].id], tds[1].id],
        [[pts[0].id], tds[2].id],
        [nil, tds[3].id]
      ]
    end

    it 'gets proper columns' do
      td = create(:trait_score).trait_descriptor
      table_data = TraitDescriptor.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0]).to eq [
        td.descriptor_label,
        td.trait_name,
        td.units_of_measurements,
        td.scoring_method,
        td.materials,
        td.plant_part.plant_part,
        1,
        td.trait.label,
        td.plant_part.label,
        [PlantTrial.first.id],
        td.id
      ]
    end
  end
end
