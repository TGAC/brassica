class PlantTrial::Treatment < ActiveRecord::Base
  belongs_to :plant_trial, touch: true, inverse_of: :treatment

  validates :plant_trial, presence: true
  validates :air_temperature_day, temperature: true, allow_nil: true
  validates :air_temperature_night, temperature: true, allow_nil: true
  validates :salt, non_negative: true, allow_nil: true
  validates :watering_temperature, temperature: true, allow_nil: true
end
