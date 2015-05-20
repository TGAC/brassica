require 'rails_helper'

RSpec.describe PlantVariety do
  describe '#filter' do
    it 'allow queries by id' do
      pvs = create_list(:plant_variety, 2)
      search = PlantVariety.filter(
        query: {
          'id' => pvs[0].id
        }
      )
      expect(search.count).to eq 1
      expect(search.first).to eq pvs[0]
    end
  end

  describe '#table_data' do
    it 'gets proper data table columns' do
      pv = create(:plant_variety)

      table_data = PlantVariety.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0]).to eq [
        pv.plant_variety_name,
        pv.crop_type,
        pv.data_attribution,
        pv.year_registered,
        pv.breeders_variety_code,
        pv.owner,
        pv.quoted_parentage,
        pv.female_parent,
        pv.male_parent,
        pv.id
      ]
    end
  end
end
