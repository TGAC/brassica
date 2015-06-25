class AddUniqueIndicesToPvCountryTables < ActiveRecord::Migration
  def up
    # Scan existing table and purge excess records
    # Temporarily add a PK to pv_coo and pv_cr
    add_column :plant_variety_country_of_origin, :id, :primary_key
    add_column :plant_variety_country_registered, :id, :primary_key
    execute "DELETE FROM plant_variety_country_of_origin WHERE id NOT IN \
      (SELECT MIN(id) FROM plant_variety_country_of_origin GROUP BY country_id, plant_variety_id);"
    execute "DELETE FROM plant_variety_country_registered WHERE id NOT IN \
      (SELECT MIN(id) FROM plant_variety_country_registered GROUP BY country_id, plant_variety_id);"
    # Remove the now-useless PKs
    remove_column :plant_variety_country_of_origin, :id
    remove_column :plant_variety_country_registered, :id

    add_index(:plant_variety_country_of_origin, [:plant_variety_id, :country_id], unique: true, name: 'unique_pv_coo_idx')
    add_index(:plant_variety_country_registered, [:plant_variety_id, :country_id], unique: true, name: 'unique_pv_cr_idx')
  end

  def down
    remove_index(:plant_variety_country_of_origin, name: 'unique_pv_coo_idx')
    remove_index(:plant_variety_country_registered, name: 'unique_pv_cr_idx')
  end
end
