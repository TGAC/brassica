require "rails_helper"

RSpec.describe Analysis::Gwas do
  let(:analysis) { create(:analysis, :gwas) }

  subject { described_class.new(analysis) }

  describe "#call" do
    let(:selected_traits) { analysis.meta.fetch("phenos") }

    context "phenotype data file based analysis" do
      let!(:phenotype_data_file) {
        create(:analysis_data_file, :gwas_phenotype, analysis: analysis, owner: analysis.owner)
      }

      context "with CSV genotype data" do
        let!(:genotype_data_file) {
          create(:analysis_data_file, :gwas_genotype_csv, analysis: analysis, owner: analysis.owner)
        }

        it "changes analysis status to success" do
          expect { subject.call }.
            to change { analysis.reload.status }.
            from("idle").to("success")
        end

        it "stores output files for selected traits" do
          expect { subject.call }.
            to change { analysis.data_files.gwas_results.count }.
            from(0).to(selected_traits.length)

          expect(analysis.data_files.gwas_results.map { |r| r.file.original_filename }).
            to match_array(selected_traits.map { |t| "SNPAssociation-Full-#{t}.csv" })
        end
      end

      context "with VCF genotype data" do
        let(:runner) { double(call: nil, results_dir: nil, store_result: nil) }
        let!(:genotype_data_file) {
          create(:analysis_data_file, :gwas_genotype_vcf, analysis: analysis, owner: analysis.owner)
        }

        subject { described_class.new(analysis, runner: runner) }

        it "converts VCF genotype file to CSV" do
          expect { subject.call }.
            to change { analysis.data_files.gwas_genotype.count }.
            from(1).to(2)

          expect(analysis.data_files.gwas_genotype.csv.count).to eq(1)
        end
      end
    end

    context "plant trial based analysis" do
      let!(:plant_trial) { create(:plant_trial, user: analysis.owner) }
      let!(:trait_descriptors) { create_list(:trait_descriptor, 5) }
      let!(:plant_scoring_units) {
        1.upto(100).map { |idx|
          create(:plant_scoring_unit, plant_trial: plant_trial, scoring_unit_name: "plant#{idx}")
        }
      }
      let!(:trait_scores) {
        plant_scoring_units.map.with_index { |psu, idx|
          create(:trait_score, plant_scoring_unit: psu, score_value: idx, trait_descriptor: trait_descriptors.sample)
        }
      }

      let!(:genotype_data_file) {
        create(:analysis_data_file, :gwas_genotype_vcf, analysis: analysis, owner: analysis.owner)
      }

      let(:runner) { double(call: nil, results_dir: nil, store_result: nil) }

      before do
        analysis.update!(meta: { plant_trial_id: plant_trial.id })
      end

      it "creates phenotype CSV from plant trial data" do
        expect { subject.call }.
          to change { analysis.data_files.gwas_phenotype.count }.
          from(0).to(1)
      end

      it "changes analysis status to success" do
        expect { subject.call }.
          to change { analysis.reload.status }.
          from("idle").to("success")
      end
    end
  end
end
