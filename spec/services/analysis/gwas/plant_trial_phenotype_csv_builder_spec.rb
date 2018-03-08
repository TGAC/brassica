require "rails_helper"

RSpec.describe Analysis::Gwas::PlantTrialPhenotypeCsvBuilder do
  let(:plant_trial) { create(:plant_trial) }
  let(:trait_names) { %w(A C B).map { |n| "trait_#{n}" } }
  let(:traits) { trait_names.map { |name| create(:trait, name: name) } }
  let(:trait_descriptors) { traits.map { |trait| create(:trait_descriptor, trait: trait) } }

  let!(:plant_scoring_units) { create_list(:plant_scoring_unit, 3, plant_trial: plant_trial) }
  let!(:trait_scores) {
    [
      create(:trait_score, trait_descriptor: trait_descriptors[0], plant_scoring_unit: plant_scoring_units[2],
                           score_value: 0),
      create(:trait_score, trait_descriptor: trait_descriptors[1], plant_scoring_unit: plant_scoring_units[0],
                           score_value: 2),
      create(:trait_score, trait_descriptor: trait_descriptors[2], plant_scoring_unit: plant_scoring_units[1],
                           score_value: 1),
    ]
  }

  let(:scoring_unit_names) { plant_scoring_units.map(&:scoring_unit_name) }

  describe "#build" do
    subject { described_class.new.build(plant_trial) }

    it "returns trait and sample names" do
      expect(subject.trait_ids).to eq %w(trait_A trait_B trait_C)
      expect(subject.sample_ids).to match_array(scoring_unit_names)
    end
  end

  describe "#build_csv" do
    subject { described_class.new.build_csv(plant_trial).first }

    it "returns CSV acceptable by GWASSER" do
      headers = subject.readline.strip.split(",")

      expect(headers).to eq(['"ID"'] + %w("trait_A" "trait_B" "trait_C"))
      expect(subject.readlines).to match_array([
        %("#{scoring_unit_names[0]}","NA","NA","2"\n),
        %("#{scoring_unit_names[1]}","NA","1","NA"\n),
        %("#{scoring_unit_names[2]}","0","NA","NA"\n)
      ])
    end
  end

end
