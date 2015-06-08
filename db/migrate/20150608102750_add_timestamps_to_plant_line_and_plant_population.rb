class AddTimestampsToPlantLineAndPlantPopulation < ActiveRecord::Migration
  def up
    add_timestamps :plant_lines
    add_timestamps :plant_populations

    safe_day = Time.now - 8.days

    PlantPopulation.update_all(
      created_at: safe_day,
      updated_at: safe_day
    )

    PlantLine.update_all(
      created_at: safe_day,
      updated_at: safe_day
    )
  end

  def down
    remove_timestamps :plant_lines
    remove_timestamps :plant_populations
  end
end
