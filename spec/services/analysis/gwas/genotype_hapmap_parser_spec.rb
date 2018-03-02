require "rails_helper"

RSpec.describe Analysis::Gwas::GenotypeHapmapParser do
  describe "#call" do
    let(:io) { StringIO.new(File.read(file)) }

    subject { described_class.new.call(io) }

    context "given good input (normal headers)" do
      let(:file) { fixture_file("hapmap/multisample.txt", "text/plain") }

      it "returns valid result" do
        expect(subject).to be_valid
        expect(subject.sample_ids).to eq(%w(NA19625 NA19700 NA19701 NA19702))
      end
    end

    context "given good input (GAPIT headers)" do
      let(:file) { fixture_file("hapmap/multisample.gapit.txt", "text/plain") }

      it "returns valid result" do
        expect(subject).to be_valid
        expect(subject.sample_ids).to eq(%w(NA19625 NA19700 NA19701 NA19702))
      end
    end

    context "given empty hapmap input" do
      let(:file) { fixture_file("hapmap/empty.txt", "text/plain") }

      it "returns error information" do
        expect(subject).not_to be_valid
        expect(subject.errors).to include(:no_mutations)
        expect(subject.errors).to include(:no_samples)
      end
    end

    context "given malformed hapmap input (wrong column)" do
      let(:file) { fixture_file("hapmap/invalid-column.txt", "text/plain") }

      it "returns error information" do
        expect(subject).not_to be_valid
        expect(subject.errors).to include([:invalid_hapmap_column, column: "allele", expected: "alleles"])
      end
    end

    context "given non-hapmap input" do
      let(:file) { fixture_file("empty.txt", "text/plain") }

      it "returns error information" do
        expect(subject).not_to be_valid
        expect(subject.errors).to include(:not_a_hapmap)
      end
    end
  end
end
