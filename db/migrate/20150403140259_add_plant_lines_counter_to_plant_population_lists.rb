class AddPlantLinesCounterToPlantPopulationLists < ActiveRecord::Migration
  def up
    add_column :plant_populations, :plant_population_lists_count, :integer, null: false, default: 0

    PlantPopulation.reset_column_information
    PlantPopulation.pluck(:id).each do |pp_id|
      PlantPopulation.reset_counters pp_id, :plant_population_lists
    end
  end

  def down
    remove_column :plant_populations, :plant_population_lists_count
  end
end
