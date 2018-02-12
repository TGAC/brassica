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
  end

  context "validations" do
    it { should validate_as_temperature(:air_temperature_day).allow_nil }
    it { should validate_as_temperature(:air_temperature_night).allow_nil }
    it { should validate_as_non_negative(:salt).allow_nil }
    it { should validate_as_temperature(:watering_temperature).allow_nil }
  end
end
