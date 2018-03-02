require "rails_helper"

RSpec.describe PlantTrial::RootingMedium do
  describe "validations" do
    let(:environment) { PlantTrial::Environment.new }
    let!(:root_treatment) { create(:plant_treatment_type) }
    let!(:growth_medium_treatment) { create(:plant_treatment_type, term: PlantTreatmentType::GROWTH_MEDIUM_ROOT_TERM) }

    context "with correct medium type" do
      subject { described_class.new(environment: environment, medium_type: growth_medium_treatment) }
      it { should be_valid }
    end

    context "with wrong medium type " do
      subject { described_class.new(environment: environment, medium_type: root_treatment) }
      it { should_not be_valid }
    end
  end
end
