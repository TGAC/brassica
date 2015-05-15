class RelatePlantPopulationsAndPlantLinesToUser < ActiveRecord::Migration
  def change
    change_table :plant_populations do |t|
      t.references :user
    end
    change_table :plant_lines do |t|
      t.references :user
    end
  end
end
