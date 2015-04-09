class DropNullConstraints < ActiveRecord::Migration
  def up
    execute "ALTER TABLE plant_lines ALTER COLUMN comments DROP NOT NULL"
  end

  def down
  end

end
