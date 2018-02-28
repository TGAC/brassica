require "rails_helper"

RSpec.describe Analysis::Gwasser::ManhattanPlot do
  let!(:analysis) { create(:analysis, :gwasser_with_results) }

  subject { described_class.new(analysis).call }

  context "with no map file available" do
    let(:expected_trait_results) {
      [
        ["snp1", 42.248475811326],
        ["snp2", 2.71525554601752],
        ["snp3", 197.525150438166]
      ]
    }

    let(:expected_tooltips) {
      [
        "<br>Mutation: snp1\n<br>-log10(p-value): 42.2485\n",
        "<br>Mutation: snp2\n<br>-log10(p-value): 2.7153\n",
        "<br>Mutation: snp3\n<br>-log10(p-value): 197.5252\n"
      ]
    }

    it "returns mutations per trait" do
      expect(subject[:traits].map { |trait| trait[0] }).to match_array(%w(trait5 trait6 trait7))
      expect(subject[:traits].map { |trait| trait[1] }).to all eq(expected_trait_results)
      expect(subject[:traits].map { |trait| trait[2] }).to all eq(expected_tooltips)
    end

    it "does not return chromosome information" do
      expect(subject[:chromosomes]).to be_empty
    end
  end

  context "with map file available" do
    let(:gwas_map_content) { tempfile("ID,Chr,cM\nsnp1,1,14\nsnp2,2,4\nsnp3,1,3", ["gwas-map", ".csv"]) }
    let!(:gwas_map) {
      create(:analysis_data_file, :gwas_map, analysis: analysis, owner: analysis.owner, file: gwas_map_content)
    }

    let(:expected_trait_results) {
      [
        ["snp3", 197.525150438166, "1", 3],
        ["snp1", 42.248475811326, "1", 14],
        ["snp2", 2.71525554601752, "2", 4]
      ]
    }

    let(:expected_tooltips) {
      [
        "<br>Mutation: snp3\n<br>-log10(p-value): 197.5252\n<br>Chromosome: 1<br>Position: 3",
        "<br>Mutation: snp1\n<br>-log10(p-value): 42.2485\n<br>Chromosome: 1<br>Position: 14",
        "<br>Mutation: snp2\n<br>-log10(p-value): 2.7153\n<br>Chromosome: 2<br>Position: 4"
      ]
    }

    it "returns sorted mutations per trait with position on chromosome " do
      expect(subject[:traits].map { |trait| trait[0] }).to match_array(%w(trait5 trait6 trait7))
      expect(subject[:traits].map { |trait| trait[1] }).to all eq(expected_trait_results)
      expect(subject[:traits].map { |trait| trait[2] }).to all eq(expected_tooltips)
    end

    it "returns chromosome information" do
      expect(subject[:chromosomes]).to eq([["1", 0, 1], ["2", 2, 2]])
    end
  end
end
