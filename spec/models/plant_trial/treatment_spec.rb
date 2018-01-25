require "rails_helper"

RSpec.describe PlantTrial::Treatment do
  context "associations" do
    it { should belong_to(:plant_trial).touch(true).inverse_of(:treatment) }
    it { should have_many(:air_applications).class_name("PlantTrial::AirTreatmentApplication") }
    it { should have_many(:antibiotic_applications).class_name("PlantTrial::AntibioticTreatmentApplication") }
    it { should have_many(:chemical_applications).class_name("PlantTrial::ChemicalTreatmentApplication") }
    it { should have_many(:biotic_applications).class_name("PlantTrial::BioticTreatmentApplication") }
    it { should have_many(:fertilizer_applications).class_name("PlantTrial::FertilizerTreatmentApplication") }
    it { should have_many(:hormone_applications).class_name("PlantTrial::HormoneTreatmentApplication") }
    it { should have_many(:fungicide_applications).class_name("PlantTrial::FungicideTreatmentApplication") }
    it { should have_many(:herbicide_applications).class_name("PlantTrial::HerbicideTreatmentApplication") }
    it { should have_many(:pesticide_applications).class_name("PlantTrial::PesticideTreatmentApplication") }
    it { should have_many(:gas_applications).class_name("PlantTrial::GaseousTreatmentApplication") }
    it { should have_many(:soil_applications).class_name("PlantTrial::SoilTreatmentApplication") }
    it { should have_many(:soil_temperature_applications).
         class_name("PlantTrial::SoilTemperatureTreatmentApplication") }
    it { should have_many(:mechanical_applications).class_name("PlantTrial::MechanicalTreatmentApplication") }
    it { should have_many(:salt_applications).class_name("PlantTrial::SaltTreatmentApplication") }
    it { should have_many(:season_applications).class_name("PlantTrial::SeasonalTreatmentApplication") }
    it { should have_many(:humidity_applications).class_name("PlantTrial::HumidityTreatmentApplication") }
    it { should have_many(:rainfall_applications).class_name("PlantTrial::RainfallTreatmentApplication") }
    it { should have_many(:watering_applications).class_name("PlantTrial::WateringTreatmentApplication") }
    it { should have_many(:gravity_applications).class_name("PlantTrial::GravityTreatmentApplication") }
    it { should have_many(:radiation_applications).class_name("PlantTrial::RadiationTreatmentApplication") }
    it { should have_many(:ph_applications).class_name("PlantTrial::PhTreatmentApplication") }
    it { should have_many(:water_temperature_applications).
         class_name("PlantTrial::WaterTemperatureTreatmentApplication") }
    it { should have_many(:measurement_values) }
  end

  context "validations" do
    it { should validate_presence_of(:plant_trial) }
  end
end
