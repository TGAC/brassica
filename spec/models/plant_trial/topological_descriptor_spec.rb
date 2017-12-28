require "rails_helper"

RSpec.describe PlantTrial::TopologicalDescriptor do
  context "associations" do
    it { should belong_to(:environment).class_name("PlantTrial::Environment") }
    it { should belong_to(:topological_factor) }
  end

  context "validations" do
    it { should validate_presence_of(:environment) }
    it { should validate_presence_of(:topological_factor) }
    it { should validate_presence_of(:description) }
  end
end
