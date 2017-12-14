class CreatePlantTrialTreatments < ActiveRecord::Migration
  def change
    create_table :plant_trial_treatments do |t|
      t.references :plant_trial, null: false, foreign_key: true, index: true
      t.timestamps null: false
    end
  end
end
