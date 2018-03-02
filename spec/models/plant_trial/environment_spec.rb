require "rails_helper"

RSpec.describe PlantTrial::Environment do
  context "associations" do
    it { should belong_to(:plant_trial).touch(true).inverse_of(:environment) }
    it { should have_many(:topological_descriptors).class_name("PlantTrial::TopologicalDescriptor") }
    it { should have_many(:lamps) }
    it { should have_many(:containers) }
    it { should have_many(:rooting_media) }
    it { should have_many(:measurement_values) }
  end

  context "validations" do
    it { should validate_presence_of(:plant_trial) }
  end
end
