require 'rails_helper'

RSpec.describe LinkageMap do
  describe '#table_data' do
    it 'gets proper columns' do
      lm = create(:linkage_map)
      create_list(:linkage_group, 2, linkage_map: lm)
      create_list(:map_locus_hit, 2, linkage_map: lm, linkage_group: nil, map_position: nil)
      table_data = LinkageMap.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0]).to eq [
        lm.plant_population.taxonomy_term.name,
        lm.plant_population.name,
        lm.linkage_map_label,
        lm.linkage_map_name,
        lm.map_version_no,
        lm.map_version_date,
        lm.linkage_groups.count,
        lm.map_locus_hits.count,
        lm.plant_population.id,
        lm.pubmed_id,
        lm.id
      ]
    end

    it 'retrieves published data only' do
      u = create(:user)
      lm1 = create(:linkage_map, user: u, published: true)
      lm2 = create(:linkage_map, user: u, published: false)

      lmd = LinkageMap.table_data
      expect(lmd.count).to eq 1

      lmd = LinkageMap.table_data(nil, u.id)
      expect(lmd.count).to eq 2
    end
  end
end
