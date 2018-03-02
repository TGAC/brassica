require "rails_helper"

RSpec.describe Submission::PlantTrialFinalizer::EnvironmentBuilder do
  let(:submission) { build(:submission, :trial, content: content) }
  let(:content) { { environment: environment_data } }
  let(:plant_trial) { PlantTrial.new }

  subject { described_class.new(submission, plant_trial).call }

  describe "#measurement values" do
    let(:environment_data) { { rooting_container_height: ["liter", 5] } }

    context "when unit exists" do
      before { create(:measurement_unit, name: "liter") }

      it "assigns measurement value" do
        expect(subject.measurement_values.size).to eq(1)
        expect(subject.measurement_values.first).to be_valid
        expect(subject.measurement_values.first.property).to eq("rooting_container_height")
        expect(subject.measurement_values.first.value).to eq(5)
        expect(subject.measurement_values.first.unit).to eq(MeasurementUnit.find_by!(name: "liter"))
      end
    end

    context "when unit cannot be found" do
      it "fails with error" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find MeasurementUnit")
      end
    end
  end

  describe "#lamps" do
    let(:environment_data) { { lamps: [["huge bulb", "5 for each plant"]] } }

    context "when lamp type exists" do
      before { create(:lamp_type, name: "huge bulb") }

      it "assigns lamps" do
        expect(subject.lamps.size).to eq(1)
        expect(subject.lamps.first).to be_valid
        expect(subject.lamps.first.lamp_type).to eq(LampType.find_by!(name: "huge bulb"))
        expect(subject.lamps.first.description).to eq("5 for each plant")
      end
    end

    context "when lamp type cannot be found" do
      it "builds new non-canonical lamp type" do
        expect(subject.lamps.size).to eq(1)
        expect(subject.lamps[0].lamp_type).to be_valid
        expect(subject.lamps[0].lamp_type).not_to be_persisted
        expect(subject.lamps[0].lamp_type.attributes).to include("name" => "huge bulb", "canonical" => false)
      end
    end
  end

  describe "#containers" do
    let(:environment_data) { { containers: [["pot", nil]] } }

    context "when container type exists" do
      before { create(:container_type, name: "pot") }

      it "assigns containers" do
        expect(subject.containers.size).to eq(1)
        expect(subject.containers.first).to be_valid
        expect(subject.containers.first.container_type).to eq(ContainerType.find_by!(name: "pot"))
        expect(subject.containers.first.description).to be_nil
      end
    end

    context "when container type cannot be found" do
      it "builds new non-canonical container type" do
        expect(subject.containers.size).to eq(1)
        expect(subject.containers[0].container_type).to be_valid
        expect(subject.containers[0].container_type).not_to be_persisted
        expect(subject.containers[0].container_type.attributes).to include("name" => "pot", "canonical" => false)
      end
    end
  end

  describe "#rooting_media" do
    let(:environment_data) { { rooting_media: [["clay soil", "high red clay content"]] } }

    let!(:root_medium_type) { create(:plant_treatment_type, name: "plant growth medium treatment",
                                                            term: PlantTreatmentType::GROWTH_MEDIUM_ROOT_TERM) }

    context "when medium type exists" do
      before do
        create(:plant_treatment_type, name: "clay soil treatment", parent_ids: [root_medium_type.id])
      end

      it "assigns rooting media" do
        expect(subject.rooting_media.size).to eq(1)
        expect(subject.rooting_media.first).to be_valid
        expect(subject.rooting_media.first.medium_type).to eq(PlantTreatmentType.find_by!(name: "clay soil treatment"))
        expect(subject.rooting_media.first.description).to eq("high red clay content")
      end
    end

    context "when medium type cannot be found" do
      let(:environment_data) { { rooting_media: [["swamp soil", "really swampy stuff"]] } }

      it "builds new non-canonical treatment type" do
        expect(subject.rooting_media.size).to eq(1)
        expect(subject.rooting_media[0].medium_type).not_to be_persisted
        expect(subject.rooting_media[0].medium_type).to be_valid
        expect(subject.rooting_media[0].medium_type.attributes).
          to include("name" => "swamp soil", "canonical" => false, "parent_ids" => [root_medium_type.id])
      end
    end
  end

  describe "#topological_descriptors" do
    let(:environment_data) { { topological_descriptors: [["slope", 30]] } }

    context "when topological factor exists" do
      before { create(:topological_factor, name: "slope") }

      it "assigns topological descriptors" do
        expect(subject.topological_descriptors.size).to eq(1)
        expect(subject.topological_descriptors.first).to be_valid
        expect(subject.topological_descriptors.first.topological_factor).
          to eq(TopologicalFactor.find_by!(name: "slope"))

        expect(subject.topological_descriptors.first.description).to eq("30")
      end
    end

    context "when factor cannot be found" do
      it "builds new non-canonical factor" do
        expect(subject.topological_descriptors.size).to eq(1)
        expect(subject.topological_descriptors[0].topological_factor).not_to be_persisted
        expect(subject.topological_descriptors[0].topological_factor).to be_valid
        expect(subject.topological_descriptors[0].topological_factor.attributes).
          to include("name" => "slope", "canonical" => false, "term" => nil)
      end
    end
  end
end
