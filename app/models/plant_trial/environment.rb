class PlantTrial::Environment < ActiveRecord::Base
  belongs_to :plant_trial, touch: true, inverse_of: :environment

  has_many :topological_descriptors
  has_many :lamps

  validates :plant_trial, presence: true
  validates :day_temperature, temperature: true, allow_nil: true
  validates :night_temperature, temperature: true, allow_nil: true
  validates :temperature_change, numericality: true, allow_nil: true
  validates :ppfd_canopy, non_negative: true, allow_nil: true
  validates :ppfd_plant, non_negative: true, allow_nil: true
  validates :light_period, non_negative: true, allow_nil: true
  validates :light_intensity, non_negative: true, allow_nil: true
  validates :light_intensity_range, non_negative: true, allow_nil: true
  validates :outside_light, non_negative: true, allow_nil: true
  validates :rfr_ratio, ratio: true, allow_nil: true
  validates :daily_uvb, non_negative: true, allow_nil: true
  validates :total_light, non_negative: true, allow_nil: true
  validates :co2_controlled, inclusion: { in: [true, false] }, allow_nil: true
  validates :co2_light, non_negative: true, allow_nil: true
  validates :co2_dark, non_negative: true, allow_nil: true
  validates :relative_humidity_light, ratio: true, allow_nil: true
  validates :relative_humidity_dark, ratio: true, allow_nil: true

  validates :rooting_container_volume, non_negative: true, allow_nil: true
  validates :rooting_container_height, non_negative: true, allow_nil: true
  validates :rooting_count, non_negative: { only_integer: true }, allow_nil: true
  validates :sowing_density, non_negative: true, allow_nil: true
  validates :soil_porosity, ratio: true, allow_nil: true
  validates :soil_penetration, non_negative: true, allow_nil: true
  validates :soil_organic_matter, ratio: true, allow_nil: true
  validates :medium_temperature, temperature: true, allow_nil: true
  validates :water_retention, numericality: true, allow_nil: true
  validates :nitrogen_concentration_start, non_negative: true, allow_nil: true
  validates :nitrogen_concentration_end, non_negative: true, allow_nil: true

  validates :conductivity, non_negative: true, allow_nil: true
end
