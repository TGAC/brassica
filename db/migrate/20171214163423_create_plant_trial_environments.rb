class CreatePlantTrialEnvironments < ActiveRecord::Migration
  def change
    create_table :plant_trial_environments do |t|
      t.references :plant_trial, null: false, foreign_key: true, index: true
      t.boolean :co2_controlled
      t.timestamps null: false
    end
  end
end
