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
  end

  def down

  end
end