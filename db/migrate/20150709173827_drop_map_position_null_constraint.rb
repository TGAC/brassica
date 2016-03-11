class DropMapPositionNullConstraint < ActiveRecord::Migration
  def up
    if column_exists?(:map_positions, :marker_assay_name)
      execute "ALTER TABLE map_positions ALTER COLUMN marker_assay_name DROP NOT NULL"
    end
  end

  def down
  end
end
