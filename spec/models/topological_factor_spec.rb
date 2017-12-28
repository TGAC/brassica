require "rails_helper"

RSpec.describe TopologicalFactor do
  context "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:term) }
  end
end
