require "rails_helper"

RSpec.describe Analysis::GenotypeCsvParser do

  subject { described_class.new.call(input) }

  context "with valid input" do
    let(:input) { fixture_file("gwas-genotypes.csv", "text/csv") }
    let(:headers) { %w(ID) + 1.upto(500).map { |id| "snp-#{id}" } }

    it "returns valid result object" do
      expect(subject).to be_valid
      expect(subject.headers).to eq(headers)
      expect(subject.csv.pos).to eq(subject.rewind(skip_header: true))
      expect(subject.csv.readline[0]).to eq("plant-1")
      expect(subject.csv.readline.size).to eq(501)
    end
  end

  context "with empty input" do
    let(:input) { StringIO.new }

    it "returns invalid result object" do
      expect(subject).not_to be_valid
      expect(subject.errors).to include(:no_id_column)
      expect(subject.errors).to include(:no_mutations)
      expect(subject.errors).to include(:no_samples)
    end
  end

  context "with misformed CSV" do
    let(:input) { "aaa,'vvvv" }

    it "returns invalid result object" do
      expect(subject).not_to be_valid
    end
  end
end
