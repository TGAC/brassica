class AllowNullForPlantPopulationListSortOrder < ActiveRecord::Migration
  def up
    execute "ALTER TABLE plant_population_lists ALTER COLUMN sort_order DROP NOT NULL"
  end

  def down
    # Do nothing
  end
end
