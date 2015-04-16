class CleanUpCountries < ActiveRecord::Migration
  def up
    remove_column :countries, :comments
    remove_column :countries, :data_provenance
  end

  def down
    add_column :countries, :comments, :text
    add_column :countries, :data_provenance, :text
  end
end