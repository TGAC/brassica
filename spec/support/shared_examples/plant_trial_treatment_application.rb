RSpec.shared_examples "PlantTrial::TreatmentApplication" do |specific_treatment_root_term|
  describe "validations" do
    let(:treatment) { PlantTrial::Treatment.new }
    let!(:root_treatment) { create(:plant_treatment_type) }
    let!(:specific_treatment) { create(:plant_treatment_type, term: specific_treatment_root_term) }

    context "with correct treatment type" do
      subject { described_class.new(treatment: treatment, treatment_type: specific_treatment) }
      it { should be_valid }
    end

    context "with wrong treatment type" do
      subject { described_class.new(treatment: treatment, treatment_type: root_treatment) }
      it { should_not be_valid }
    end
  end
end
