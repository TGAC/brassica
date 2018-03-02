require "rails_helper"

RSpec.describe Analysis::Gwas::GenotypeVcfParser do
  describe "#call" do
    let(:io) { StringIO.new(File.read(file)) }

    subject { described_class.new.call(io) }

    context "given good input" do
      let(:file) { fixture_file("vcf/multisample.vcf", "text/vcf") }

      it "returns valid result" do
        expect(subject).to be_valid
        expect(subject.sample_ids).to eq(%w(Original s1t1 s2t1 s3t1 s1t2 s2t2 s3t2))
      end
    end

    context "given empty VCF input" do
      let(:file) { fixture_file("vcf/empty.vcf", "text/vcf") }

      it "returns error information" do
        expect(subject).not_to be_valid
        expect(subject.errors).to include(:no_mutations)
        expect(subject.errors).to include(:no_samples)
      end
    end

    context "given non-VCF input" do
      let(:file) { fixture_file("empty.txt", "text/plain") }

      it "returns error information" do
        expect(subject).not_to be_valid
        expect(subject.errors).to include(:not_a_vcf)
      end
    end
  end
end
