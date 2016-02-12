class AddQtlsCounterToLinkageGroups < ActiveRecord::Migration
  def up
    add_column :linkage_groups, :qtls_count, :integer, null: false, default: 0

    LinkageGroup.reset_column_information
    LinkageGroup.pluck(:id).each do |lg_id|
      LinkageGroup.reset_counters lg_id, :qtls
    end
  end

  def down
    remove_column :linkage_groups, :qtls_count
  end
end
