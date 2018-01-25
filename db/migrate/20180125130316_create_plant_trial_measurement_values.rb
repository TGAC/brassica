class CreatePlantTrialMeasurementValues < ActiveRecord::Migration
  def change
    create_table :plant_trial_measurement_values do |t|
      t.references :context, polymorphic: true
      t.float :value, null: false
      t.string :property, null: false
      t.json :constraints
      t.timestamps null: false
    end

    add_index :plant_trial_measurement_values, [:context_type, :context_id, :property], unique: true,
      name: "idx_plant_trial_measurement_values"
  end
end
