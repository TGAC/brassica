class AddSynonymsToPlantVarieties < ActiveRecord::Migration
  def change
    add_column :plant_varieties, :synonyms, :text, array: true, default: []
  end
end
