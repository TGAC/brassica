require "rails_helper"

RSpec.describe Analysis::Gwas::GenotypeVcfToCsvConverter do
  describe "#call" do
    let(:vcf_path) { Rails.root.join(*%w(spec fixtures files vcf multisample.vcf)).to_s }

    let(:sample_names) { %w(Original s1t1 s2t1 s3t1 s1t2 s2t2 s3t2) }
    let(:mutation_names) {
      %w(1.10257 1.10291 1.10297 1.10303 1.10315 1.10321 1.10327 1.10583 1.10665
          1.10694 1.10723 1.12783 1.13116 1.13118 1.13178 1.13302 1.13757 X13868)
    }

    let(:output_values) {
      {
        "Original": %w(1 2 2 2 2 2 2 2 NA NA NA 2 2 2 2 1 1 2),
        "s3t2": %w(1 2 2 1 1 2 2 2 1 NA NA 2 2 2 1 2 1 2 2)
      }
    }

    subject { described_class.new.call(vcf_path) }

    it "outputs csv file" do
      CSV.open(subject.path, headers: false) do |csv|
        expect(csv.readline).to eq(%w(ID) + mutation_names)

        sample_names.each do |sample_name|
          sample = csv.readline
          expect(sample.first).to eq(sample_name)

          if output_values.key?(sample_name)
            expect(sample[1..-1]).to eq(output_values[sample_name])
          end
        end
      end
    end
  end
end
