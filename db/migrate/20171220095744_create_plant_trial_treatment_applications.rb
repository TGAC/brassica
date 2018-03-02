class CreatePlantTrialTreatmentApplications < ActiveRecord::Migration
  def change
    create_table :plant_trial_treatment_applications do |t|
      t.string :sti_type, null: false
      t.integer :treatment_id, null: false
      t.integer :treatment_type_id, null: false
      t.text :description

      t.timestamps null: false
    end

    add_foreign_key :plant_trial_treatment_applications, :plant_trial_treatments, column: :treatment_id
    add_foreign_key :plant_trial_treatment_applications, :plant_treatment_types, column: :treatment_type_id

    add_index :plant_trial_treatment_applications, [:treatment_id, :treatment_type_id],
      name: "idx_plant_trial_treatment_applications"
  end
end
