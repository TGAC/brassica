require "rails_helper"

RSpec.describe LampType do
  context "validations" do
    subject { LampType.new(name: "Huge bulb") }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end
end
