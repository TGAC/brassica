class RemoveMisleadingPlantPopulationDescriptions < ActiveRecord::Migration
  def up
    execute(
      "UPDATE plant_populations SET description = NULL WHERE id IN (" +
      "119, 120, 118, 131, 109, 108, 107, 96, 95, 94, 117, 126, 148, " +
      "87, 86, 85, 143, 100, 99, 129, 128, 139, 138, 137, 136, 135, " +
      "115, 116, 142, 110, 123, 125" +
      ");"
    )
  end

  def down
  end
end
