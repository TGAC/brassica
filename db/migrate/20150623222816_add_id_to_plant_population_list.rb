class AddIdToPlantPopulationList < ActiveRecord::Migration
  def change
    add_column :plant_population_lists, :id, :primary_key
  end
end
