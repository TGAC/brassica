class PlantTrial::Environment < ActiveRecord::Base
  def self.measured_properties
    {
      day_temperature: { numericality: true },
      night_temperature: { numericality: true },
      temperature_change: { numericality: true },
      ppfd_canopy: { non_negative: true },
      ppfd_plant: { non_negative: true },
      light_period: { non_negative: true },
      light_intensity: { non_negative: true },
      light_intensity_range: { non_negative: true },
      outside_light_loss: { non_negative: true },
      rfr_ratio: { percentage: true },
      daily_uvb: { non_negative: true },
      total_light: { non_negative: true },
      co2_light: { non_negative: true },
      co2_dark: { non_negative: true },
      relative_humidity_light: { percentage: true },
      relative_humidity_dark: { percentage: true },
      rooting_container_volume: { non_negative: true },
      rooting_container_height: { non_negative: true },
      rooting_count: { non_negative: { only_integer: true } },
      sowing_density: { non_negative: true },
      soil_porosity: { percentage: true },
      soil_penetration: { non_negative: true },
      soil_organic_matter: { percentage: true },
      medium_temperature: { numericality: true },
      water_retention: { numericality: true },
      nitrogen_concentration_start: { non_negative: true },
      nitrogen_concentration_end: { non_negative: true },
      conductivity: { non_negative: true }
    }
  end

  def self.dictionary_properties
    %i(topological_descriptors lamps containers rooting_media)
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
