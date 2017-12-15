class CreateTreatments < ActiveRecord::Migration
  def change
    create_table :treatments do |t|
      t.references :plant_trial, null: false, foreign_key: true, index: true
      t.float :air_temperature_day
      t.float :air_temperature_night
      t.float :salt
      t.float :watering_temperature
      t.text :other

      t.timestamps null: false
    end
  end
end
