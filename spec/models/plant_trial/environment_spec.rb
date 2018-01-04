require "rails_helper"

RSpec.describe PlantTrial::Environment do
  context "associations" do
    it { should belong_to(:plant_trial).touch(true).inverse_of(:environment) }
    it { should have_many(:topological_descriptors).class_name("PlantTrial::TopologicalDescriptor") }
    it { should have_many(:lamps) }
    it { should have_many(:containers) }
  end

  context "validations" do
    it { should validate_presence_of(:plant_trial) }
    it { should validate_as_temperature(:day_temperature).allow_nil }
    it { should validate_as_temperature(:night_temperature).allow_nil }
    it { should validate_numericality_of(:temperature_change).allow_nil }
    it { should validate_as_non_negative(:ppfd_canopy).allow_nil }
    it { should validate_as_non_negative(:ppfd_plant).allow_nil }
    it { should validate_as_non_negative(:light_period).allow_nil }
    it { should validate_as_non_negative(:light_intensity).allow_nil }
    it { should validate_as_non_negative(:light_intensity_range).allow_nil }
    it { should validate_as_non_negative(:outside_light).allow_nil }
    it { should validate_as_ratio(:rfr_ratio).allow_nil }
    it { should validate_as_non_negative(:daily_uvb).allow_nil }
    it { should validate_as_non_negative(:total_light).allow_nil }
    it { should validate_as_non_negative(:co2_light).allow_nil }
    it { should validate_as_non_negative(:co2_dark).allow_nil }
    it { should validate_as_ratio(:relative_humidity_light).allow_nil }
    it { should validate_as_ratio(:relative_humidity_dark).allow_nil }

    it { should validate_as_non_negative(:rooting_container_volume).allow_nil }
    it { should validate_as_non_negative(:rooting_container_height).allow_nil }
    it { should validate_as_non_negative(:rooting_count).only_integer.allow_nil }
    it { should validate_as_non_negative(:sowing_density).allow_nil }
    it { should validate_as_ratio(:soil_porosity).allow_nil }
    it { should validate_as_non_negative(:soil_penetration).allow_nil }
    it { should validate_as_ratio(:soil_organic_matter).allow_nil }
    it { should validate_as_temperature(:medium_temperature).allow_nil }
    it { should validate_numericality_of(:water_retention).allow_nil }
    it { should validate_as_non_negative(:nitrogen_concentration_start).allow_nil }
    it { should validate_as_non_negative(:nitrogen_concentration_end).allow_nil }
    it { should validate_as_non_negative(:conductivity).allow_nil }
  end
end
