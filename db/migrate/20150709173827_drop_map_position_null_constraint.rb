class DropMapPositionNullConstraint < ActiveRecord::Migration
  def up
    execute "ALTER TABLE map_positions ALTER COLUMN marker_assay_name DROP NOT NULL"
  end

  def down
  end
end
