class DropVersions < ActiveRecord::Migration

  def up
    drop_table :version if table_exists? :version
  end

  def down
  end

end