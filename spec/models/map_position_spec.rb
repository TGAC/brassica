require 'rails_helper'

RSpec.describe MapPosition do
  describe '#filter' do
    it 'will query by permitted params' do
      mps = create_list(:map_position, 2)
      filtered = MapPosition.filter(
        query: { 'linkage_groups.id' => mps[0].linkage_group.id }
      )
      expect(filtered.count).to eq 1
      expect(filtered.first).to eq mps[0]
      filtered = MapPosition.filter(
        query: { 'population_loci.id' => mps[0].population_locus.id }
      )
      expect(filtered.count).to eq 1
      expect(filtered.first).to eq mps[0]
    end
  end

  describe '#table_data' do
    it 'gets proper data table columns' do
      mp = create(:map_position)

      table_data = MapPosition.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0]).to eq [
        mp.marker_assay_name,
        mp.map_position,
        mp.linkage_group.linkage_group_label,
        mp.population_locus.mapping_locus,
        mp.linkage_group.id,
        mp.population_locus.id,
        mp.id
      ]
    end
  end
end
