require "rails_helper"

RSpec.describe PlantTrial::Container do
  context "associations" do
    it { should belong_to(:environment).class_name("PlantTrial::Environment") }
    it { should belong_to(:container_type) }
  end

  context "validations" do
    it { should validate_presence_of(:environment) }
    it { should validate_presence_of(:container_type) }
    it { should validate_presence_of(:description) }
  end
end
