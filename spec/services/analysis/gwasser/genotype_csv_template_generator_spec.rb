require "rails_helper"

RSpec.describe Analysis::Gwasser::GenotypeCsvTemplateGenerator do
  context "with no plant trial given" do
    subject { described_class.new.call.split("\n") }

    it "returns CSV string with fake sample names" do
      expect(subject[0]).to eq("ID,Plant-sample-id-1,Plant-sample-id-2,Plant-sample-id-3")
      expect(sample_id(subject[1])).to eq("SNP-1")
      expect(sample_id(subject[2])).to eq("SNP-2")
      expect(sample_id(subject[3])).to eq("SNP-3")
      expect(sample_id(subject[4])).to eq("SNP-4")
    end
  end

  context "with plant trial given" do
    let(:plant_trial) { create(:plant_trial) }
    let!(:plant_scoring_units) { create_list(:plant_scoring_unit, 3, plant_trial: plant_trial) }
    let(:scoring_unit_names) { plant_scoring_units.map(&:scoring_unit_name).sort }

    subject { described_class.new(plant_trial).call.split("\n") }

    it "returns a CSV string with trial's sample names" do
      expect(subject[0]).to eq((["ID"] + scoring_unit_names).join(","))
      expect(sample_id(subject[1])).to eq("SNP-1")
      expect(sample_id(subject[2])).to eq("SNP-2")
      expect(sample_id(subject[3])).to eq("SNP-3")
      expect(sample_id(subject[4])).to eq("SNP-4")
    end
  end

  def sample_id(csv_line)
    csv_line.split(",")[0]
  end
end
