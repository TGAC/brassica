class AddTimestampsToPlantPopulationList < ActiveRecord::Migration
  def up
    add_timestamps :plant_population_lists

    safe_day = Time.now - 8.days

    PlantPopulationList.update_all(
      created_at: safe_day,
      updated_at: safe_day
    )
  end

  def down
    remove_timestamps :plant_population_lists
  end
end
