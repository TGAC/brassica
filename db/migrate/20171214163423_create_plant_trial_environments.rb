class CreatePlantTrialEnvironments < ActiveRecord::Migration
  def change
    create_table :plant_trial_environments do |t|
      t.references :plant_trial, null: false, foreign_key: true, index: true
      t.float :day_temperature
      t.float :night_temperature
      t.float :temperature_change
      t.float :ppfd_canopy
      t.float :ppfd_plant
      t.float :light_period
      t.float :light_intensity
      t.float :light_intensity_range
      t.float :outside_light
      t.float :rfr_ratio
      t.float :daily_uvb
      t.float :total_light
      t.boolean :co2_controlled
      t.float :co2_light
      t.float :co2_dark
      t.float :relative_humidity_light
      t.float :relative_humidity_dark

      t.float :rooting_container_volume
      t.float :rooting_container_height
      t.integer :rooting_count
      t.float :sowing_density
      t.float :soil_porosity
      t.float :soil_penetration
      t.float :soil_organic_matter
      t.float :medium_temperature
      t.float :water_retention
      t.float :nitrogen_concentration_start
      t.float :nitrogen_concentration_end

      t.float :conductivity

      t.timestamps null: false
    end
  end
end
