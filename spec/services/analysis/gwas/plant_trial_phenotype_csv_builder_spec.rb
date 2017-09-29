require "rails_helper"

RSpec.describe Analysis::Gwas::PlantTrialPhenotypeCsvBuilder do
  let(:plant_trial) { create(:plant_trial) }
  let!(:plant_scoring_units) { create_list(:plant_scoring_unit, 3, plant_trial: plant_trial) }
  let!(:trait_scores) {
    plant_scoring_units.map.with_index { |psu, idx|
      create(:trait_score, plant_scoring_unit: psu, score_value: idx)
    }
  }

  let(:trait_names) { trait_scores.map { |ts| ts.trait_descriptor.trait_name } }
  let(:scoring_unit_names) { plant_scoring_units.map(&:scoring_unit_name) }

  describe "#build" do
    subject { described_class.new.build(plant_trial) }

    it "returns trait and sample names" do
      expect(subject.trait_ids).to match_array(trait_names)
      expect(subject.sample_ids).to match_array(scoring_unit_names)
    end
  end

  describe "#build_csv" do
    subject { described_class.new.build_csv(plant_trial).first }

    it "returns CSV acceptable by GWASSER" do
      headers = subject.readline.strip.split(",")

      expect(headers).to eq(['"ID"'] + trait_names.map { |t| %("#{t}") })
      expect(subject.readlines).to match_array([
        %("#{scoring_unit_names[0]}","0","NA","NA"\n),
        %("#{scoring_unit_names[1]}","NA","1","NA"\n),
        %("#{scoring_unit_names[2]}","NA","NA","2"\n)
      ])
    end
  end

end
