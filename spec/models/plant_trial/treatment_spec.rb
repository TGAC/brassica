require "rails_helper"

RSpec.describe PlantTrial::Treatment do
  context "associations" do
    it { should belong_to(:plant_trial).touch(true).inverse_of(:treatment) }
  end

  context "validations" do
    it { should validate_as_temperature(:air_temperature_day).allow_nil }
    it { should validate_as_temperature(:air_temperature_night).allow_nil }
    it { should validate_as_non_negative(:salt).allow_nil }
    it { should validate_as_temperature(:watering_temperature).allow_nil }
  end
end
