require "rails_helper"

RSpec.describe Analysis::Gwas::GenotypeVcfToCsvConverter do
  describe "#call" do
    let(:vcf_path) { Rails.root.join(*%w(spec fixtures files vcf multisample.vcf)).to_s }

    let(:sample_names) { %w(Original s1t1 s2t1 s3t1 s1t2 s2t2 s3t2) }
    let(:mutation_names) {
      %w(1.10257_A_C 1.10291_C_T 1.10297_C_T 1.10303_C_T 1.10315_C_T 1.10321_C_T
          1.10327_T_C 1.10583_G_A 1.10665_C_G
          1.10694_C_G 1.10723_C_G 1.12783_G_A 1.13116_T_G 1.13118_A_G 1.13178_G_A
          1.13302_C_T 1.13757_G_A X13868_A_G X13868_A_T X13868_A_C)
    }
    let(:mutation_names_to_ignore) {
      %w(1.10291_C_T 1.10583_G_A 1.10327_T_C 1.10694_C_G 1.13118_A_G 1.13116_T_G 1.12783_G_A)
    }

    let(:output_values) {
      {
        "Original": %w(1 2 2 2 2 2 2 2 NA NA NA 2 2 2 2 1 1 2),
        "s3t2": %w(1 2 2 1 1 2 2 2 1 NA NA 2 2 2 1 2 1 2 2)
      }
    }

    subject { described_class.new.call(vcf_path) }

    let(:status) { subject[0] }
    let(:geno_csv) { subject[1] }
    let(:map_csv) { subject[2] }

    it "outputs geno CSV file" do
      expect(status).to eq(:ok)

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
      expect(status).to eq(:ok)

      CSV.open(geno_csv.path, headers: false) do |csv|
        expect(csv.readline[-3..-1]).to eq(mutation_names[-3..-1])
      end
    end

    it "outputs map CSV file" do
      expect(status).to eq(:ok)

      CSV.open(map_csv.path, headers: false) do |csv|
        expect(csv.readline).to eq(%w(ID Chr cM))
        expect(csv.readlines.map { |r| r[0] }).to eq(mutation_names - mutation_names_to_ignore)
      end
    end

    it "returns metadata" do
      expect(subject[3]).to match_array(mutation_names_to_ignore)
      expect(subject[4]).to eq(sample_names)
    end
  end
end
