require "rails_helper"

RSpec.describe Submission::PlantTrialTreatmentParser do
  subject { described_class.new.call(filepath) }

  context "with valid file" do
    let(:filepath) { fixture_file_path("plant-trial-treatment.xls") }

    it "returns valid result" do
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
    end

    it "returns filled in treatments" do
      expect(subject.treatment).to eq({
        antibiotic_applications: ["Antibiotic regime", [["hygromycin treatment", "20mM; 20ml per plant; every week"]]],
        chemical_applications: ["Chemical administration", [["bion", "13,5mM; 5ml per plant; every 15 days"]]],
        season_applications: [
          "Seasonal environment", [["dry season treatment", "really dry"], ["kharif season treatment", nil]]
        ],
        biotic_applications: ["Biotic treatment", [["Spodoptera praefica treatment", nil]]],
        fungicide_applications: ["Fungicide regime", [["benzothiadiazole treatment", "strong stuff"]]],
        gas_applications: ["Gaseous regime", [["anaerobic environment treatment", "CO2"]]],
        fertilizer_applications: [
          "Fertilizer regime", [["ammonium nitrate treatment", nil], ["bone meal treatment", nil],
                                ["sodium nitrate treatment", nil], ["fish meal treatment", nil]]
        ],
        gravity_applications: ["Gravity", [["zero gravity treatment", nil]]],
        hormone_applications: ["Growth hormone regime", [["auxin treatment", nil]]],
        mechanical_applications: ["Mechanical treatment", [["mechanical damage treatment", nil]]],
        humidity_applications: ["Humidity regimen", [["humidity treatment", "Constant 100% humidity"]]],
        herbicide_applications: ["Herbicide regime", [["diuron treatment", nil]]],
        radiation_applications: ["Radiation regime", [["IR light treatment", nil]]],
        rainfall_applications: ["Rainfall regime", [["rainfall treatment", nil]]],
        pesticide_applications: ["Pesticide regime", [["benzothiadiazole treatment", nil]]],
        ph_applications: ["pH regime", [["basic pH growth media environment treatment", nil]]],
        air_applications: ["Air treatment regime", [["freezing air temperature treatment", nil]]],
        watering_applications: ["Watering regime", [["watering treatment", nil]]],
        water_temperature_applications: [
          "Water temperature regime", [["cold water temperature treatment", "4 degree Celcius"]]
        ],
        soil_temperature_applications: ["Soil temperature regime", [["Soil temperature treatment", nil]]],
        soil_applications: ["Soil treatment regime", [["loam soil treatment", nil]]],
        salt_applications: ["Salt regime", [["sodium chloride treatment", nil]]]
      })
    end
  end

  context "with empty template" do
    let(:filepath) { fixture_file_path("plant-trial-treatment.empty.xls") }

    it "returns valid and empty result" do
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.treatment).to be_empty
    end
  end

  context "with completely empty xls" do
    let(:filepath) { fixture_file_path("xls/empty.xls") }

    it "returns invalid result" do
      expect(subject).not_to be_valid
      expect(subject.errors).to include(:no_treatment_sheet)
    end
  end
end
