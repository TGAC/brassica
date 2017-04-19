require "rails_helper"

RSpec.describe Analysis::Gwas::GenotypeVcfToCsvConverter do
  describe "#call" do
    let(:vcf_path) { Rails.root.join(*%w(spec fixtures files vcf multisample.vcf)).to_s }

    let(:sample_names) { %w(Original s1t1 s2t1 s3t1 s1t2 s2t2 s3t2) }
    let(:mutation_names) {
      %w(1.10257-A-C 1.10291-C-T 1.10297-C-T 1.10303-C-T 1.10315-C-T 1.10321-C-T
          1.10327-T-C 1.10583-G-A 1.10665-C-G
          1.10694-C-G 1.10723-C-G 1.12783-G-A 1.13116-T-G 1.13118-A-G 1.13178-G-A
          1.13302-C-T 1.13757-G-A X13868-A-G X13868-A-T X13868-A-C)
    }

    let(:output_values) {
      {
        "Original": %w(1 2 2 2 2 2 2 2 NA NA NA 2 2 2 2 1 1 2),
        "s3t2": %w(1 2 2 1 1 2 2 2 1 NA NA 2 2 2 1 2 1 2 2)
      }
    }

    subject { described_class.new.call(vcf_path) }

    let(:geno_csv) { subject.first }
    let(:map_csv) { subject.last }

    it "outputs geno CSV file" do
      CSV.open(geno_csv.path, headers: false) do |csv|
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

    it "produces separate geno CSV column for each alternate allele in a VCF record" do
      CSV.open(geno_csv.path, headers: false) do |csv|
        expect(csv.readline[-3..-1]).to eq(mutation_names[-3..-1])
      end
    end

    it "outputs map CSV file" do
      CSV.open(map_csv.path, headers: false) do |csv|
        expect(csv.readline).to eq(%w(ID Chr cM))
        expect(csv.readlines.map { |r| r[0] }).to eq(mutation_names)
      end
    end
  end
end
