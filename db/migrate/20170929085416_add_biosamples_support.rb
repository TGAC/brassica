class AddBiosamplesSupport < ActiveRecord::Migration
  def up
    add_column :plant_scoring_units, :biosamples_id, :string
    
    PlantScoringUnit.reset_column_information
    
    add_data_from_file("db/data/Biosample_example_Rapeseed_Earlham_seeds_updated.csv")
    add_data_from_file("db/data/Biosample_example_Rapeseed_Earlham_leafs_updated.csv")
  end
  
  
  def add_data_from_file(filename)
    
    CSV.foreach(filename, :headers => true) do |row|
      sql = <<-SQL
        UPDATE  plant_scoring_units AS psu
        SET biosamples_id = '#{row["BiosampleID"]}'
        FROM plant_accessions AS pa
        WHERE (psu.plant_accession_id = pa.id 
        AND concat_ws(':',psu.data_owned_by,pa.plant_accession) = '#{row["accession"]}' )
      SQL
      connection.execute(sql)
    end
    
  end
  
  
  def down
    remove_column :plant_scoring_units, :biosamples_id
  end
end

