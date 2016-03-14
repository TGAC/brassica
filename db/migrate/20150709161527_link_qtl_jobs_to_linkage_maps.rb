class LinkQtlJobsToLinkageMaps < ActiveRecord::Migration
  require File.expand_path('lib/migration_helper')
  include MigrationHelper

  def up
    # Replace FK in qtl_jobs
    if QtlJob.column_for_attribute('linkage_map_id').type == :text
      execute("ALTER TABLE qtl_jobs RENAME COLUMN linkage_map_id TO linkage_map_label")
      replace_fk('qtl_jobs', 'linkage_maps', 'linkage_map_label',
                 'linkage_map_id', 'linkage_map_label')
      if column_exists?(:qtl_jobs, :linkage_map_label)
        execute("ALTER TABLE qtl_jobs ALTER COLUMN linkage_map_label DROP NOT NULL")
      end
    else
      puts "Table qtl_jobs already contains a numerical FK for linkage_maps. Skipping."
    end
  end

   def down
    # Do nothing.
  end
end