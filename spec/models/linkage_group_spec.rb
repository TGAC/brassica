require 'rails_helper'

RSpec.describe LinkageGroup do
  describe '#table_data' do
    it 'gets proper columns' do
      lg = create(:linkage_group)
      mps = create_list(:map_position, 1, linkage_group: lg)
      create_list(:map_locus_hit, 2, linkage_group: lg, map_position: mps[0])
      table_data = LinkageGroup.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0]).to eq [
        lg.linkage_group_label,
        lg.linkage_group_name,
        lg.total_length,
        lg.lod_threshold,
        lg.consensus_group_assignment,
        lg.consensus_group_orientation,
        lg.map_positions.count,
        lg.map_locus_hits.count,
        lg.id
      ]
    end
  end
end
