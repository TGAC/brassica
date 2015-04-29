class DropRedundantPopulationId < ActiveRecord::Migration
  def up
    if column_exists?(:processed_trait_datasets, :plant_population_id)
      remove_column :processed_trait_datasets, :plant_population_id
    end
  end

  def down
  end

end