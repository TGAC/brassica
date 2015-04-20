class AddPubmedidFields < ActiveRecord::Migration
  def up
    add_column :plant_trials, :pubmed_id, :integer
    add_column :qtl, :pubmed_id, :integer
    add_column :linkage_maps, :pubmed_id, :integer
  end

  def down
    remove_column :plant_trials, :pubmed_id
    remove_column :qtl, :pubmed_id
    remove_column :linkage_maps, :pubmed_id
  end
end