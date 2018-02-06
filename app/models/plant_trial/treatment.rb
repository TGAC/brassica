class PlantTrial::Treatment < ActiveRecord::Base
  def self.treatment_types
    [:air_applications, :antibiotic_applications, :chemical_applications, :biotic_applications,
     :fertilizer_applications, :hormone_applications, :fungicide_applications, :herbicide_applications,
     :pesticide_applications, :gas_applications, :soil_applications, :soil_temperature_applications,
     :mechanical_applications, :salt_applications, :season_applications, :humidity_applications,
     :rainfall_applications, :watering_applications, :water_temperature_applications,
     :gravity_applications, :radiation_applications, :ph_applications]
  end

  belongs_to :plant_trial, touch: true, inverse_of: :treatment

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

  def treatment_applications
    self.class.treatment_types.flat_map do |type|
      send("#{type}_applications").to_a
    end
  end
end
