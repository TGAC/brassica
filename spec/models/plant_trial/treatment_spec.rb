require "rails_helper"

RSpec.describe PlantTrial::Treatment do
  context "associations" do
    it { should belong_to(:plant_trial).touch(true).inverse_of(:treatment) }
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
    it { should have_many(:mechanical_applications).class_name("PlantTrial::MechanicalTreatmentApplication") }
    it { should have_many(:salt_applications).class_name("PlantTrial::SaltTreatmentApplication") }
    it { should have_many(:season_applications).class_name("PlantTrial::SeasonalTreatmentApplication") }
    it { should have_many(:humidity_applications).class_name("PlantTrial::HumidityTreatmentApplication") }
    it { should have_many(:rainfall_applications).class_name("PlantTrial::RainfallTreatmentApplication") }
    it { should have_many(:watering_applications).class_name("PlantTrial::WateringTreatmentApplication") }
  end

  context "validations" do
    it { should validate_as_temperature(:air_temperature_day).allow_nil }
    it { should validate_as_temperature(:air_temperature_night).allow_nil }
    it { should validate_as_non_negative(:salt).allow_nil }
    it { should validate_as_temperature(:watering_temperature).allow_nil }
  end
end
