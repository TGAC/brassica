class CreatePlantVarietyAccessions < ActiveRecord::Migration
  def change
    create_view :plant_variety_accessions
  end
end
