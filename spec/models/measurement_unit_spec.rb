require "rails_helper"

RSpec.describe MeasurementUnit do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:term) }
    # TODO: validate uniqueness too
  end

  describe ".descendants_of" do
    let!(:unit_a) { create(:measurement_unit) }
    let!(:unit_b) { create(:measurement_unit, parent_ids: [unit_a.id]) }
    let!(:unit_c) { create(:measurement_unit, parent_ids: [unit_b.id]) }

    it "returns given record with all descendants" do
      expect(MeasurementUnit.descendants_of(unit_a)).to match_array([unit_a, unit_b, unit_c])
      expect(MeasurementUnit.descendants_of(unit_b)).to match_array([unit_b, unit_c])
      expect(MeasurementUnit.descendants_of(unit_c)).to match_array([unit_c])
    end

    it "accepts term as string" do
      expect(MeasurementUnit.descendants_of(unit_a.term)).to match_array([unit_a, unit_b, unit_c])
      expect(MeasurementUnit.descendants_of(unit_b.term)).to match_array([unit_b, unit_c])
      expect(MeasurementUnit.descendants_of(unit_c.term)).to match_array([unit_c])
    end
  end
end
