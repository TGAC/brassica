require 'rails_helper'

RSpec.describe PlantVariety do
  describe '#filter' do
    it 'allows queries by id' do
      pvs = create_list(:plant_variety, 2)
      search = PlantVariety.filter(
        query: {
          'id' => pvs[0].id
        }
      )
      expect(search.count).to eq 1
      expect(search.first).to eq pvs[0]
    end

    # Just a sample from the allowed query params list
    it 'allows queries by quoted_parentage' do
      pvs = create_list(:plant_variety, 2)
      search = PlantVariety.filter(
        query: {
          'quoted_parentage' => pvs[0].quoted_parentage
        }
      )
      expect(search.count).to eq 1
      expect(search.first).to eq pvs[0]
    end

    # Just a sample ffrom the disallowed query param list
    it 'disallows queries by entered_by_whom' do
      create(:plant_variety, entered_by_whom: 'him')
      search = PlantVariety.filter(
        query: {
          'entered_by_whom' => 'him'
        }
      )
      expect(search.count).to eq 0
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

    it 'retrieves published data only' do
      u = create(:user)
      pv1 = create(:plant_variety, user: u, published: true)
      pv2 = create(:plant_variety, user: u, published: false)

      pvd = PlantVariety.table_data
      expect(pvd.count).to eq 1

      User.current_user_id = u.id

      pvd = PlantVariety.table_data
      expect(pvd.count).to eq 2
    end
  end
end
