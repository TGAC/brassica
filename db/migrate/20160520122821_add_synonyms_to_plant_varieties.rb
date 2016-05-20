class AddSynonymsToPlantVarieties < ActiveRecord::Migration
  def change
    add_column :plant_varieties, :synonyms, :text, default: '', null: true
  end
end
