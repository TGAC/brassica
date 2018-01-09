require "rails_helper"

RSpec.describe Analysis::Gwas::GenotypeHapmapToCsvConverter do
  describe "#call" do
    context "valid file" do
      let(:hapmap_path) { Rails.root.join(*%w(spec fixtures files hapmap multisample.txt)).to_s }

      let(:sample_names) { %w(NA19625 NA19700 NA19701 NA19702) }
      let(:mutation_names) {
        %w(rs12255619 rs11252546 rs7909677 rs10904494 rs11591988 rs4508132
          rs10904561 rs7917054 rs7906287 rs12775579 rs4495823 rs0000001 rs0000002)
      }
      let(:mutation_names_to_ignore) {
        %w(rs11252546 rs7909677 rs10904494 rs11591988 rs12775579 rs0000002)
      }

      let(:output_values) {
        {
          "NA19625": %w(0 2 0 0 0 0 2 0 2 0 NA 1),
          "NA19700": %w(0 2 0 0 0 1 1 2 1 0 0 1),
          "NA19701": %w(1 2 0 0 0 0 2 0 2 0 0 1),
          "NA19702": %w(0 2 0 0 0 1 2 1 1 0 1 1)
        }
      }

      subject { described_class.new.call(hapmap_path) }

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

      it "outputs map CSV file" do
        expect(status).to eq(:ok)

        CSV.open(map_csv.path, headers: false) do |csv|
          expect(csv.readline).to eq(%w(ID Chr cM))
          expect(csv.readlines.map { |r| r[0] }).to eq(mutation_names - mutation_names_to_ignore)
        end
      end
    end

    context "invalid file" do
      let(:hapmap_path) { Rails.root.join(*%w(spec fixtures files hapmap invalid-value.txt)).to_s }

      it "fails with error" do
        expect { subject.call(hapmap_path) }.
          to raise_error("Value XX not understood")
      end
    end
  end
end
