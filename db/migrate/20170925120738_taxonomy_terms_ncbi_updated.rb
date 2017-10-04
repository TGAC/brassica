require 'csv'   

class TaxonomyTermsNcbiUpdated < ActiveRecord::Migration
  def up
    add_column :taxonomy_terms, :ncbi_taxon, :string 
    
    TaxonomyTerm.reset_column_information
 
    filename = "db/data/taxonomy_terms_ncbi_updated.csv"
    
    CSV.foreach(filename, :headers => true) do |row|
      sql = <<-SQL
        UPDATE  taxonomy_terms set ncbi_taxon = '#{row["ncbi_taxon"]}' WHERE taxonomy_terms.id = #{row["ID"]}
      SQL
      connection.execute(sql)
    end
   
  end
  
  def down
    remove_column :taxonomy_terms, :ncbi_taxon
  end
end
