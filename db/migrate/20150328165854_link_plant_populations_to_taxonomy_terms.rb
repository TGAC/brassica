class LinkPlantPopulationsToTaxonomyTerms < ActiveRecord::Migration
  def up
    add_reference :plant_populations, :taxonomy_term, index: true
  end

  def down
    remove_column :plant_populations, :taxonomy_term_id
  end

end