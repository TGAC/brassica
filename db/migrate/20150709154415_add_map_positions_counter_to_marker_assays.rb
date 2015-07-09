class AddMapPositionsCounterToMarkerAssays < ActiveRecord::Migration
  def up
    add_column :marker_assays, :map_positions_count, :integer, null: false, default: 0

    MarkerAssay.reset_column_information
    MarkerAssay.pluck(:id).each do |ma_id|
      MarkerAssay.reset_counters ma_id, :map_positions
    end
  end

  def down
    remove_column :marker_assays, :map_positions_count
  end
end
