class RelateVariousModelsToUser < ActiveRecord::Migration
  def change
    change_table :plant_varieties do |t|
      t.references :user
    end
    change_table :plant_scoring_units do |t|
      t.references :user
    end
    change_table :plant_trials do |t|
      t.references :user
    end
    change_table :plant_accessions do |t|
      t.references :user
    end
    change_table :trait_descriptors do |t|
      t.references :user
    end
    change_table :trait_scores do |t|
      t.references :user
    end
  end
end
