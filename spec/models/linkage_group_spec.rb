require 'rails_helper'

RSpec.describe LinkageGroup do
  describe '#table_data' do
    it 'gets proper columns' do
      lg = create(:linkage_group)
      create_list(:linkage_map, 3).each do |lm|
        lg.linkage_maps << lm
      end
      table_data = LinkageGroup.table_data
      expect(table_data.count).to eq 1
      expect(table_data[0]).to eq [
        lg.linkage_group_label,
        lg.linkage_group_name,
        lg.total_length,
        lg.lod_threshold,
        lg.consensus_group_assignment,
        lg.consensus_group_orientation,
        lg.linkage_maps.count,
        lg.id
      ]
    end
  end
end
