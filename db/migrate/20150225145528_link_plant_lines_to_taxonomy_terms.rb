class LinkPlantLinesToTaxonomyTerms < ActiveRecord::Migration
  def up
    add_reference :plant_lines, :taxonomy_term, index: true
    add_column :taxonomy_terms, :canonical, :boolean, default: true
  end

  def down
    remove_column :plant_lines, :taxonomy_term_id
    remove_column :taxonomy_terms, :canonical
  end

end