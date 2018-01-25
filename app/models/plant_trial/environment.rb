class PlantTrial::Environment < ActiveRecord::Base
  def self.measured_properties
    {
      day_temperature: { temperature: true, allow_nil: true },
      night_temperature: { temperature: true, allow_nil: true },
      temperature_change: { numericality: true, allow_nil: true },
      ppfd_canopy: { non_negative: true, allow_nil: true },
      ppfd_plant: { non_negative: true, allow_nil: true },
      light_period: { non_negative: true, allow_nil: true },
      light_intensity: { non_negative: true, allow_nil: true },
      light_intensity_range: { non_negative: true, allow_nil: true },
      outside_light: { non_negative: true, allow_nil: true },
      rfr_ratio: { ratio: true, allow_nil: true },
      daily_uvb: { non_negative: true, allow_nil: true },
      total_light: { non_negative: true, allow_nil: true },
      co2_light: { non_negative: true, allow_nil: true },
      co2_dark: { non_negative: true, allow_nil: true },
      relative_humidity_light: { ratio: true, allow_nil: true },
      relative_humidity_dark: { ratio: true, allow_nil: true },
      rooting_container_volume: { non_negative: true, allow_nil: true },
      rooting_container_height: { non_negative: true, allow_nil: true },
      rooting_count: { non_negative: { only_integer: true }, allow_nil: true },
      sowing_density: { non_negative: true, allow_nil: true },
      soil_porosity: { ratio: true, allow_nil: true },
      soil_penetration: { non_negative: true, allow_nil: true },
      soil_organic_matter: { ratio: true, allow_nil: true },
      medium_temperature: { temperature: true, allow_nil: true },
      water_retention: { numericality: true, allow_nil: true },
      nitrogen_concentration_start: { non_negative: true, allow_nil: true },
      nitrogen_concentration_end: { non_negative: true, allow_nil: true },
      conductivity: { non_negative: true, allow_nil: true }
    }
  end

  belongs_to :plant_trial, touch: true, inverse_of: :environment

  has_many :measurement_values, as: :context

  has_many :topological_descriptors
  has_many :lamps
  has_many :containers
  has_many :rooting_media

  validates :plant_trial, presence: true

  validates :co2_controlled, inclusion: { in: [true, false] }, allow_nil: true
end
