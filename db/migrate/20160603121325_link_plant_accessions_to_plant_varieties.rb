class LinkPlantAccessionsToPlantVarieties < ActiveRecord::Migration
  def change
    add_reference :plant_accessions, :plant_variety, index: true
    add_foreign_key :plant_accessions, :plant_varieties, on_delete: :nullify, on_update: :cascade
  end
end