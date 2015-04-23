class MarkProcessedDatasetsForCuration < ActiveRecord::Migration
  def up
    if column_exists?(:processed_trait_datasets, :population_id)
      remove_column :processed_trait_datasets, :population_id
    end
  end

  def down
  end

end