class AddIdToPlantPopulationList < ActiveRecord::Migration
  def change
    unless column_exists?(:plant_population_lists, :id)
      execute "ALTER TABLE plant_population_lists DROP CONSTRAINT IF EXISTS plant_population_lists_pkey"
      add_column :plant_population_lists, :id, :primary_key
    end
  end
end
