class RefactorLinkageGroups < ActiveRecord::Migration
  require File.expand_path('lib/migration_helper')
  include MigrationHelper

  def up
    unless column_exists?(:linkage_groups, :linkage_map_id)
      add_column :linkage_groups, :linkage_map_id, :integer
      lgs = execute("SELECT id FROM linkage_groups")
      lgs.each do |lg|
        lm = execute("SELECT linkage_map_id FROM map_linkage_group_lists WHERE linkage_group_id = #{lg['id']}")
        puts "Found lm: #{lm.first['linkage_map_id']}"
        execute ("UPDATE linkage_groups SET linkage_map_id = #{lm.first['linkage_map_id']} WHERE id = #{lg['id']}")
      end

      if table_exists?(:map_linkage_group_lists)
        execute("DROP TABLE map_linkage_group_lists")
      end
    end

    unless column_exists?(:linkage_maps, :linkage_groups_count)
      add_column :linkage_maps, :linkage_groups_count, :integer, null: false, default: 0
      LinkageMap.reset_column_information
      LinkageMap.pluck(:id).each do |object_id|
        LinkageMap.reset_counters object_id, :linkage_groups
      end
    end

    if column_exists?(:linkage_maps, :map_linkage_group_lists_count)
      remove_column :linkage_maps, :map_linkage_group_lists_count
    end

    if column_exists?(:linkage_groups, :map_linkage_group_lists_count)
      remove_column :linkage_groups, :map_linkage_group_lists_count
    end
  end

  def down

  end
end