class MarkProcessedDatasetsForCuration < ActiveRecord::Migration
  def up
    if column_exists?(:processed_trait_datasets, :population_id)
      execute("UPDATE processed_trait_datasets SET comments = '!!CURATION ALERT!! Unknown plant population ID: BolAGDH05' where population_id = 'BolAGDH_05'")
    end
  end

  def down
    execute("UPDATE processed_trait_datasets SET comments = 'no comment' WHERE population_id = 'BolAGDH_05'")
  end

end