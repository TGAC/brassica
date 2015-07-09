class LinkMapPositionsToMarkerAssays < ActiveRecord::Migration
  require File.expand_path('lib/migration_helper')
  include MigrationHelper

  def up
    # Replace FK in map_positions
    unless column_exists?(:map_positions, :marker_assay_id)
      replace_fk('map_positions', 'marker_assays', 'marker_assay_name',
          'marker_assay_id', 'marker_assay_name')
    else
      puts "Table map_positions already contains a numerical FK for marker_assays. Skipping."
    end
  end


  def down
    # Do nothing.
  end
end