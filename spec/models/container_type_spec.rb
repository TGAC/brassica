require "rails_helper"

RSpec.describe ContainerType do
  context "validations" do
    subject { ContainerType.new(name: "Huge pot") }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end
end
