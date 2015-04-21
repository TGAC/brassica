class DropDataStatusFromLinkageGroups < ActiveRecord::Migration

  def up
    remove_column :linkage_groups, :data_status
  end

  def down
    add_column :linkage_groups, :data_status, :text
  end

end