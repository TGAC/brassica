require 'rails_helper'

RSpec.describe LinkageMap do
  describe '#table_data' do
    it 'gets proper columns' do
      lm = create(:linkage_map)
      create_list(:linkage_group, 2).each do |lg|
        lm.linkage_groups << lg
      end
      create_list(:map_locus_hit, 2, linkage_map: lm)
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
  end
end
