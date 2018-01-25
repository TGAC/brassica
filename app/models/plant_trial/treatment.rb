class PlantTrial::Treatment < ActiveRecord::Base
  def self.measured_properties
    {
      air_temperature_day: { temperature: true },
      air_temperature_night: { temperature: true },
      salt: { non_negative: true },
      watering_temperature: { temperature: true }
    }
  end

  belongs_to :plant_trial, touch: true, inverse_of: :treatment

  has_many :measurement_values, as: :context

  has_many :air_applications, class_name: "PlantTrial::AirTreatmentApplication", inverse_of: :treatment
  has_many :antibiotic_applications, class_name: "PlantTrial::AntibioticTreatmentApplication", inverse_of: :treatment
  has_many :chemical_applications, class_name: "PlantTrial::ChemicalTreatmentApplication", inverse_of: :treatment
  has_many :biotic_applications, class_name: "PlantTrial::BioticTreatmentApplication", inverse_of: :treatment
  has_many :fertilizer_applications, class_name: "PlantTrial::FertilizerTreatmentApplication", inverse_of: :treatment
  has_many :hormone_applications, class_name: "PlantTrial::HormoneTreatmentApplication", inverse_of: :treatment
  has_many :fungicide_applications, class_name: "PlantTrial::FungicideTreatmentApplication", inverse_of: :treatment
  has_many :herbicide_applications, class_name: "PlantTrial::HerbicideTreatmentApplication", inverse_of: :treatment
  has_many :pesticide_applications, class_name: "PlantTrial::PesticideTreatmentApplication", inverse_of: :treatment
  has_many :gas_applications, class_name: "PlantTrial::GaseousTreatmentApplication", inverse_of: :treatment
  has_many :soil_applications, class_name: "PlantTrial::SoilTreatmentApplication", inverse_of: :treatment
  has_many :soil_temperature_applications, class_name: "PlantTrial::SoilTemperatureTreatmentApplication", inverse_of: :treatment
  has_many :mechanical_applications, class_name: "PlantTrial::MechanicalTreatmentApplication", inverse_of: :treatment
  has_many :salt_applications, class_name: "PlantTrial::SaltTreatmentApplication", inverse_of: :treatment
  has_many :season_applications, class_name: "PlantTrial::SeasonalTreatmentApplication", inverse_of: :treatment
  has_many :humidity_applications, class_name: "PlantTrial::HumidityTreatmentApplication", inverse_of: :treatment
  has_many :rainfall_applications, class_name: "PlantTrial::RainfallTreatmentApplication", inverse_of: :treatment
  has_many :watering_applications, class_name: "PlantTrial::WateringTreatmentApplication", inverse_of: :treatment
  has_many :water_temperature_applications, class_name: "PlantTrial::WaterTemperatureTreatmentApplication", inverse_of: :treatment
  has_many :gravity_applications, class_name: "PlantTrial::GravityTreatmentApplication", inverse_of: :treatment
  has_many :radiation_applications, class_name: "PlantTrial::RadiationTreatmentApplication", inverse_of: :treatment
  has_many :ph_applications, class_name: "PlantTrial::PhTreatmentApplication", inverse_of: :treatment

  validates :plant_trial, presence: true
end
