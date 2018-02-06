require "rails_helper"

RSpec.describe Submission::PlantTrialFinalizer::TreatmentBuilder do
  let(:submission) { build(:submission, :trial, content: content) }
  let(:content) { { treatment: treatment_data } }
  let(:plant_trial) { PlantTrial.new }

  subject { described_class.new(submission, plant_trial).call }

  describe "building treatment applications" do
    context "when treatment type exists" do
      let(:treatment_data) { {
        hormone_applications: [["cytokinin treatment", "Makes them grow fast"],
                               ["auxin treatment", "Makes them grow big"]]
      } }

      let!(:root_treatment_type) { create(:plant_treatment_type, name: "growth hormone treatment",
                                                                 term: PlantTreatmentType::HORMONE_ROOT_TERM) }

      before do
        create(:plant_treatment_type, name: "cytokinin treatment", parent_ids: [root_treatment_type.id])
        create(:plant_treatment_type, name: "auxin treatment", parent_ids: [root_treatment_type.id])
      end

      it "assigns rooting media" do
        expect(subject.hormone_applications.size).to eq(2)
        expect(subject.hormone_applications).to all be_valid

        expect(subject.hormone_applications[0].treatment_type).
          to eq(PlantTreatmentType.find_by!(name: "cytokinin treatment"))

        expect(subject.hormone_applications[1].treatment_type).
          to eq(PlantTreatmentType.find_by!(name: "auxin treatment"))

        expect(subject.hormone_applications[0].description).to eq("Makes them grow fast")
        expect(subject.hormone_applications[1].description).to eq("Makes them grow big")
      end
    end

    context "when treatment type cannot be found" do
      let(:treatment_data) { {
        gas_applications: [["N2O treatment", "Used as a sedative before picking crops"]]
      } }

      let!(:root_treatment_type) { create(:plant_treatment_type, name: "growth hormone treatment",
                                                                 term: PlantTreatmentType::GASEOUS_ROOT_TERM) }

      it "builds new non-canonical treatment type" do
        expect(subject.gas_applications.size).to eq(1)
        expect(subject.gas_applications[0].treatment_type).not_to be_persisted
        expect(subject.gas_applications[0].treatment_type).to be_valid
        expect(subject.gas_applications[0].treatment_type.attributes).
          to include("name" => "N2O treatment", "canonical" => false, "parent_ids" => [root_treatment_type.id])
      end
    end
  end
end
