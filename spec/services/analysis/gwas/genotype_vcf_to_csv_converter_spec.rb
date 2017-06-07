require "rails_helper"

RSpec.describe Analysis::Gwas::GenotypeVcfToCsvConverter do
  describe "#call" do
    let(:vcf_path) { Rails.root.join(*%w(spec fixtures files vcf multisample.vcf)).to_s }

    let(:sample_names) { %w(Original s1t1 s2t1 s3t1 s1t2 s2t2 s3t2) }
    let(:mutation_names) {
      %w(1_10257_A_C 1_10291_C_T 1_10297_C_T 1_10303_C_T 1_10315_C_T 1_10321_C_T
          1_10327_T_C 1_10583_G_A 1_10665_C_G
          1_10694_C_G 1_10723_C_G 1_12783_G_A 1_13116_T_G 1_13118_A_G 1_13178_G_A
          1_13302_C_T 1_13757_G_A X13868_A_G X13868_A_T X13868_A_C)
    }
    let(:mutation_names_to_ignore) {
      %w(1_10291_C_T 1_10583_G_A 1_10327_T_C 1_10694_C_G 1_13118_A_G 1_13116_T_G 1_12783_G_A)
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
        expect(csv.readline).to eq(%w(ID) + (mutation_names - mutation_names_to_ignore))

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
        expect(csv.readlines.map { |r| r[0] }).to eq(mutation_names - mutation_names_to_ignore)
      end
    end
  end
end
