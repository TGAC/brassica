require "rails_helper"

RSpec.describe PlantTrial::Lamp do
  context "associations" do
    it { should belong_to(:environment).class_name("PlantTrial::Environment") }
    it { should belong_to(:lamp_type) }
  end

  context "validations" do
    it { should validate_presence_of(:environment) }
    it { should validate_presence_of(:lamp_type) }
    it { should validate_presence_of(:description) }
  end
end
