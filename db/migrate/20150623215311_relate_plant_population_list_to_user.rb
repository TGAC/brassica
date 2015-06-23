class RelatePlantPopulationListToUser < ActiveRecord::Migration
  def change
    change_table :plant_population_lists do |t|
      t.references :user
    end
  end
end
