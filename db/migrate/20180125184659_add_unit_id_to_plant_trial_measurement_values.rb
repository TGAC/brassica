class AddUnitIdToPlantTrialMeasurementValues < ActiveRecord::Migration
  def change
    add_column :plant_trial_measurement_values, :unit_id, :integer, null: false
    add_foreign_key :plant_trial_measurement_values, :measurement_units, column: :unit_id
  end
end
