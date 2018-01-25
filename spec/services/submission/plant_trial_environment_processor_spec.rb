require "rails_helper"

RSpec.describe Submission::PlantTrialEnvironmentProcessor do
  let(:upload) { build(:submission_upload, :plant_trial_environment) }
  let(:submission) { upload.submission }
  let(:parser) { instance_double("Submission::PlantTrialEnvironmentParser") }

  subject { described_class.new(upload, parser) }

  context "when parser encounters errors" do
    let(:errors) { [:no_environment_sheet] }
    let(:parser_result) { Submission::PlantTrialEnvironmentParser::Result.new(errors, {}) }

    it "adds errors to upload" do
      allow(parser).to receive(:call).with(upload.file.path).and_return(parser_result)

      subject.call

      expect(upload.errors[:file]).to match_array(["contents invalid. 'Environment' sheet missing."])
    end
  end

  context "with no parsing errors" do
    let(:parser_result) { Submission::PlantTrialEnvironmentParser::Result.new([], environment_data) }
    let(:environment_data) { {} }

    before { allow(parser).to receive(:call).with(upload.file.path).and_return(parser_result) }

    context "with no parsed data" do
      it "appends error to upload" do
        subject.call

        expect(upload.errors[:file]).to match_array(["contains no data."])
      end
    end

    context "for numeric measurement" do
      context "with invalid unit" do
        let(:environment_data) { { day_temperature: ["Average day temperature", [["Foobar", 7]]] } }

        it "appends error to upload" do
          subject.call

          expect(upload.errors[:file]).to match_array(["contains invalid unit 'Foobar' for 'Average day temperature.'"])
        end
      end

      context "with invalid value" do
        let(:environment_data) { { day_temperature: ["Average day temperature", [["degree Celcius", "very cold"]]] } }

        before { create(:measurement_unit, name: "degree Celcius") }

        it "appends error to upload" do
          subject.call

          expect(upload.errors[:file]).to match_array(
            ["contains invalid value 'very cold' for 'Average day temperature.' Value is not a number."]
          )
        end
      end

      context "with missing value" do
        let(:environment_data) { {
          day_temperature: ["Average day temperature", [["degree Celcius", 20]]],
          night_temperature: ["Average night temperature", [["degree Celcius", nil]]]
        } }

        before { create(:measurement_unit, name: "degree Celcius") }

        it "ignores the value" do
          subject.call

          expect(upload.errors[:file]).to be_empty
          expect(submission.content.environment).not_to have_key("night_temperature")
        end
      end

      context "with multiple values" do
        let(:environment_data) { {
          day_temperature: ["Average day temperature", [["degree Celcius", 20], ["degree Celcius", 34]]]
        } }

        it "appends error to upload" do
          subject.call

          expect(upload.errors[:file]).to match_array(
            ["contains multiple values for 'Average day temperature' but a single value is required."]
          )
        end
      end

      context "with valid data" do
        let(:environment_data) { {
          day_temperature: ["Average day temperature", [["degree Celcius", 20]]]
        } }

        before { create(:measurement_unit, name: "degree Celcius") }

        it "appends data to submission's content" do
          subject.call

          expect(submission.content.environment["day_temperature"]).to eq(["degree Celcius", 20])
        end
      end
    end

    context "for ontology-based relationship" do
      context "with given term" do
        let(:environment_data) { {
          lamps: ["Lamps", [["fluorescent tubes", "super bright"]]]
        } }

        it "appends data to sumission's content" do
          pending

          subject.call

          expect(submission.content.treatment["antibiotic_applications"]).
            to eq([["unknown treatment", "20mM; 20ml per plant; every week"]])
        end
      end

      context "with missing term" do
        let(:environment_data) { {
          lamps: ["Lamps", [[nil, "super bright"]]]
        } }

        it "appends error to upload" do
          subject.call

          expect(upload.errors[:file]).to match_array(["contents invalid. Missing type for 'Lamps.'"])
        end
      end
    end

    context "for boolean property" do
      context "with multiple values" do
        let(:environment_data) { {
          co2_controlled: ["Athmospheric CO2 concentration", [["controlled", nil], ["uncontrolled", nil]]]
        } }

        it "appends error to upload" do
          subject.call

          expect(upload.errors[:file]).to match_array(
            ["contains multiple values for 'Athmospheric CO2 concentration' but a single value is required."]
          )
        end
      end

      context "with valid data" do
        let(:environment_data) { {
          co2_controlled: ["Athmospheric CO2 concentration", [["controlled", nil]]]
        } }

        it "appends data to submission's content" do
          subject.call

          expect(submission.content.environment["co2_controlled"]).to eq("controlled")
        end
      end
    end
  end
end
