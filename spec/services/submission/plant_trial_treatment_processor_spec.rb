require "rails_helper"

RSpec.describe Submission::PlantTrialTreatmentProcessor do
  let(:upload) { build(:submission_upload, :plant_trial_treatment) }
  let(:submission) { upload.submission }
  let(:parser) { instance_double("Submission::PlantTrialTreatmentParser") }

  subject { described_class.new(upload, parser) }

  context "when parser encounters errors" do
    let(:errors) { [:no_treatment_sheet] }
    let(:parser_result) { Submission::PlantTrialTreatmentParser::Result.new(errors, {}) }

    it "adds errors to upload" do
      allow(parser).to receive(:call).with(upload.file.path).and_return(parser_result)

      subject.call

      expect(upload.errors[:file]).to match_array(["contents invalid. 'Treatment' sheet missing."])
    end
  end

  context "with no parsing errors" do
    let(:parser_result) { Submission::PlantTrialTreatmentParser::Result.new([], treatment_data) }
    let(:treatment_data) { {} }

    before { allow(parser).to receive(:call).with(upload.file.path).and_return(parser_result) }

    context "with no parsed data" do
      it "appends error to upload" do
        subject.call

        expect(upload.errors[:file]).to match_array(["contains no data."])
      end
    end

    context "for ontology-based relationship" do
      context "with given term" do
        let(:treatment_data) { {
          antibiotic: ["Antibiotic regime", [["unknown treatment", "20mM; 20ml per plant; every week"]]]
        } }

        it "appends data to sumission's content" do
          subject.call

          expect(submission.content.treatment["antibiotic"]).
            to eq([["unknown treatment", "20mM; 20ml per plant; every week"]])
        end
      end

      context "with missing term" do
        let(:treatment_data) { {
          antibiotic: ["Antibiotic regime", [[nil, "20mM; 20ml per plant; every week"]]]
        } }

        it "appends error to upload" do
          subject.call

          expect(upload.errors[:file]).
            to match_array(["contents invalid. Missing treatment type for 'Antibiotic regime.'"])
        end
      end
    end
  end
end
