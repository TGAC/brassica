require "rails_helper"

RSpec.describe PlantTrial::MeasurementValue do
  describe "associations" do
    it { should belong_to(:context) }
    it { should belong_to(:unit).class_name("MeasurementUnit") }
  end

  describe "validations" do
    context "with ration: true constaint" do
      subject { described_class.new(constraints: { percentage: true }) }
      it { should validate_as_percentage(:value) }
    end

    context "with non_negative: true constaint" do
      subject { described_class.new(constraints: { non_negative: true }) }
      it { should validate_as_non_negative(:value) }
    end

    context "with numericality: true constaint" do
      subject { described_class.new(constraints: { numericality: true }) }
      it { should validate_numericality_of(:value) }
    end
  end
end
