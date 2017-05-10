require "rails_helper"

RSpec.describe Analysis::Gwas::GenotypeCsvTemplateGenerator do
  context "with no plant trial given" do
    subject { described_class.new.call.split("\n") }

    it "returns CSV string with fake sample names" do
      expect(subject[0]).to eq("ID,SNP-1,SNP-2,SNP-3,SNP-4")
      expect(sample_id(subject[1])).to eq("Plant-sample-id-1")
      expect(sample_id(subject[2])).to eq("Plant-sample-id-2")
      expect(sample_id(subject[3])).to eq("Plant-sample-id-3")
    end
  end

  context "with plant trial given" do
    let(:plant_trial) { create(:plant_trial) }
    let!(:plant_scoring_units) { create_list(:plant_scoring_unit, 3, plant_trial: plant_trial) }
    let(:scoring_unit_names) { plant_scoring_units.map(&:scoring_unit_name).sort }

    subject { described_class.new(plant_trial).call.split("\n") }

    it "returns a CSV string with trial's sample names" do
      expect(subject[0]).to eq("ID,SNP-1,SNP-2,SNP-3,SNP-4")
      expect(sample_id(subject[1])).to eq(scoring_unit_names[0])
      expect(sample_id(subject[2])).to eq(scoring_unit_names[1])
      expect(sample_id(subject[3])).to eq(scoring_unit_names[2])
    end
  end

  def sample_id(csv_line)
    csv_line.split(",")[0]
  end
end
