require "rails_helper"

RSpec.describe PlantTreatmentType do
  context "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:term) }
  end

  describe ".descendants_of" do
    let!(:treatment_a) { create(:plant_treatment_type) }
    let!(:treatment_b) { create(:plant_treatment_type, parent_ids: [treatment_a.id]) }
    let!(:treatment_c) { create(:plant_treatment_type, parent_ids: [treatment_b.id]) }

    it "returns given record with all descendants" do
      expect(PlantTreatmentType.descendants_of(treatment_a)).to match_array([treatment_a, treatment_b, treatment_c])
      expect(PlantTreatmentType.descendants_of(treatment_b)).to match_array([treatment_b, treatment_c])
      expect(PlantTreatmentType.descendants_of(treatment_c)).to match_array([treatment_c])
    end

    it "accepts term as string" do
      expect(PlantTreatmentType.descendants_of(treatment_a.term)).to match_array([treatment_a, treatment_b, treatment_c])
      expect(PlantTreatmentType.descendants_of(treatment_b.term)).to match_array([treatment_b, treatment_c])
      expect(PlantTreatmentType.descendants_of(treatment_c.term)).to match_array([treatment_c])
    end
  end
end
