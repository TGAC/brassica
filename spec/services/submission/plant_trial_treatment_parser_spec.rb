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
        antibiotic: ["Antibiotic regime", [["hygromycin treatment", "20mM; 20ml per plant; every week"]]],
        chemical: ["Chemical administration", [["bion", "13,5mM; 5ml per plant; every 15 days"]]],
        season: [
          "Seasonal environment", [["dry season treatment", "really dry"], ["kharif season treatment", nil]]
        ],
        biotic: ["Biotic treatment", [["Spodoptera praefica treatment", nil]]],
        fungicide: ["Fungicide regime", [["benzothiadiazole treatment", "strong stuff"]]],
        gas: ["Gaseous regime", [["anaerobic environment treatment", "CO2"]]],
        fertilizer: [
          "Fertilizer regime", [["ammonium nitrate treatment", nil], ["bone meal treatment", nil],
                                ["sodium nitrate treatment", nil], ["fish meal treatment", nil]]
        ],
        gravity: ["Gravity", [["zero gravity treatment", nil]]],
        hormone: ["Growth hormone regime", [["auxin treatment", nil]]],
        mechanical: ["Mechanical treatment", [["mechanical damage treatment", nil]]],
        humidity: ["Humidity regimen", [["humidity treatment", "Constant 100% humidity"]]],
        herbicide: ["Herbicide regime", [["diuron treatment", nil]]],
        radiation: ["Radiation regime", [["IR light treatment", nil]]],
        rainfall: ["Rainfall regime", [["rainfall treatment", nil]]],
        pesticide: ["Pesticide regime", [["benzothiadiazole treatment", nil]]],
        ph: ["pH regime", [["basic pH growth media environment treatment", nil]]],
        air: ["Air treatment regime", [["freezing air temperature treatment", nil]]],
        watering: ["Watering regime", [["watering treatment", nil]]],
        water_temperature: [
          "Water temperature regime", [["cold water temperature treatment", "4 degree Celcius"]]
        ],
        soil_temperature: ["Soil temperature regime", [["Soil temperature treatment", nil]]],
        soil: ["Soil treatment regime", [["loam soil treatment", nil]]],
        salt: ["Salt regime", [["sodium chloride treatment", nil]]]
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
