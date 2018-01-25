require "rails_helper"

RSpec.describe Submission::PlantTrialEnvironmentParser do
  subject { described_class.new.call(filepath) }

  context "with valid file" do
    let(:filepath) { fixture_file_path("plant-trial-environment.xls") }

    it "returns valid result" do
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
    end

    it "returns filled in environment properties" do
      expect(subject.environment).to eq({
        co2_dark: ["Average CO2 during the dark periods", [["milliliter per liter", nil]]],
        co2_light: ["Average CO2 during the light periods", [["milliliter per liter", nil]]],
        conductivity: ["Electrical conductivity", [["dS m–1", nil]]],
        daily_uvb: ["Daily UV-B radiation", [["watt per square meter", nil]]],
        day_temperature: ["Average day temperature", [["degree Celsius", 22.0]]],
        light_intensity: ["Light intensity", [["μmol m–2 s–1", nil]]],
        light_intensity_range: ["Range in peak light intensity", [["μmol m–2 s–1", nil]]],
        light_period: ["Average length of the light period", [["hour", 16.0]]],
        medium_temperature: ["Medium temperature", [["degree Celsius", nil]]],
        night_temperature: ["Average night temperature", [["degree Celsius", 14.0]]],
        nitrogen_content: [
          "Extractable N content per unit ground area before fertiliser added",
          [["milligram per square meter", nil]]
        ],
        nitrogen_concentration_end: [
          "Extractable N content per unit ground area at the end of the experiment",
          [["milligram per square meter", nil]]
        ],
        nitrogen_concentration_start: [
          "Concentration of Nitrogen before start of the experiment",
          [["milligram per liter", nil]]
        ],
        outside_light_loss: [
          "Fraction of outside light intercepted by growth facility components and surrounding structures",
          [["μmol m–2 s–1", nil]]
        ],
        ph: ["Soil pH", [[7.7, "40-60"], [6.5, nil], [4.3, "10-20"]]],
        ppfd_plant: [
          "Average daily integrated photosynthetic photon flux density (PPFD) measured at plant level",
          [["μmol m–2 s–1", nil]]
        ],
        relative_humidity_dark: ["Average relative humidity during the dark period", [["percent", nil]]],
        relative_humidity_light: ["Average relative humidity during the light period", [["percent", nil]]],
        rooting_container_volume: ["Container volume", [["liter", nil]]],
        rooting_container_type: ["Container height", [["meter", nil]]],
        rooting_count: ["Number of plants per container", [["count unit", nil]]],
        rfr_ratio: ["R/FR ratio", [["mole per mole", nil]]],
        soil_organic_matter: ["Organic matter content", [["percent", nil]]],
        soil_penetration: ["Soil penetration stength", [["pascal per square meter", nil]]],
        soil_porosity: ["Porosity", [["percent", nil]]],
        temperature_change: ["Change over the course of experiment", [["degree Celsius", 0.75]]],
        total_light: ["Total daily irradiance", [["watt per square meter", nil]]],
        water_retention: ["Water retention capacity", [["gram per gram dry weight", nil]]],
        containers: ["Container type", [["pot", nil]]],
        rooting_media: ["Rooting medium", [["clay soil", "high red clay content"]]],
        co2_controlled: ["Atmospheric CO2 concentration", [["uncontrolled", nil]]]
      })
    end
  end

  context "with empty template" do
    let(:filepath) { fixture_file_path("plant-trial-environment.empty.xls") }

    it "returns valid and empty result" do
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.environment).to be_empty
    end
  end

  context "with empty xls" do
    let(:filepath) { fixture_file_path("xls/empty.xls") }

    it "returns invalid result" do
      expect(subject).not_to be_valid
      expect(subject.errors).to include(:no_environment_sheet)
    end
  end
end
