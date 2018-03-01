require "rails_helper"

RSpec.describe Analysis::Gwasser do
  let(:analysis) { create(:analysis, :gwasser) }

  let(:csv_genotype_data_file) {
    create(:analysis_data_file, :gwas_genotype_csv, analysis: analysis, owner: analysis.owner)
  }

  let(:csv_genotype_data_file_with_no_relevant_mutations) {
    create(:analysis_data_file,
           :gwas_genotype_csv_with_no_relevant_mutations, analysis: analysis, owner: analysis.owner)
  }

  let(:vcf_genotype_data_file) {
    create(:analysis_data_file, :gwas_genotype_vcf, analysis: analysis, owner: analysis.owner)
  }

  let(:vcf_genotype_data_file_with_no_relevant_mutations) {
    create(:analysis_data_file,
           :gwas_genotype_vcf_with_no_relevant_mutations, analysis: analysis, owner: analysis.owner)
  }

  let(:csv_phenotype_data_file) {
    create(:analysis_data_file, :gwas_phenotype, analysis: analysis, owner: analysis.owner)
  }

  let(:csv_phenotype_data_file_with_no_relevant_traits) {
    create(:analysis_data_file,
           :gwas_phenotype_with_no_relevant_traits, analysis: analysis, owner: analysis.owner)
  }

  subject { described_class.new(analysis) }

  describe "#call" do
    context "phenotype data file based analysis" do
      context "valid CSV phenotype data" do
        let!(:phenotype_data_file) { csv_phenotype_data_file }

        context "valid CSV genotype data" do
          let!(:genotype_data_file) { csv_genotype_data_file }

          let(:selected_traits) { analysis.meta.fetch("phenos") }

          it "runs successfully" do
            expect { subject.call }.
              to change { analysis.reload.status }.
              from("idle").to("success")

            expect(analysis.meta).to include('geno_samples' => (1..95).map { |n| "plant-#{n}" })
            expect(analysis.meta).to include('pheno_samples' => (6..50).map { |n| "plant-#{n}" })
            expect(analysis.meta).to include('removed_mutations' => %w(snp-1 snp-2))
            expect(analysis.meta).to include('removed_traits' => %w(trait_1))
            expect(analysis.meta).to include('traits_results' => {
              "trait_5" => "SNPAssociation-Full-trait_5.csv",
              "trait_6" => "SNPAssociation-Full-trait_6.csv",
              "trait_7" => "SNPAssociation-Full-trait_7.csv"
            })
          end

          it "stores output files for selected traits" do
            expect { subject.call }.
              to change { analysis.data_files.gwas_results.count }.
              from(0).to(selected_traits.length)

            expect(analysis.data_files.gwas_results.map { |r| r.file.original_filename }).
              to match_array(selected_traits.map { |t| "SNPAssociation-Full-#{t}.csv" })
          end
        end

        context "CSV genotype data with no relevant mutations" do
          let!(:genotype_data_file) { csv_genotype_data_file_with_no_relevant_mutations }

          it "fails" do
            expect { subject.call }.
              to change { analysis.reload.status }.
              from("idle").to("failure")

            expect(analysis.meta).to include('failure_reason' => "all_mutations_removed")
          end
        end

        context "valid VCF genotype data" do
          let(:runner) { double(call: nil, results_dir: nil, store_result: nil) }
          let!(:genotype_data_file) { vcf_genotype_data_file }

          subject { described_class.new(analysis, runner: runner) }

          it "converts VCF genotype file to CSV" do
            expect { subject.call }.
              to change { analysis.data_files.gwas_genotype.count }.
              from(1).to(2)

            expect(analysis.data_files.gwas_genotype.csv.count).to eq(1)

            expect(analysis.meta).to include('removed_mutations' => %w(snp-4_G_C))
            expect(analysis.meta).to include('removed_traits' => %w(trait_1))
          end
        end

        context "VCF genotype data with no relevant mutations" do
          let!(:genotype_data_file) { vcf_genotype_data_file_with_no_relevant_mutations }

          it "fails" do
            expect { subject.call }.
              to change { analysis.reload.status }.
              from("idle").to("failure")

            expect(analysis.meta).to include('failure_reason' => "all_mutations_removed")
          end
        end
      end

      context "CSV phenotype data with no relevant traits" do
        let!(:phenotype_data_file) { csv_phenotype_data_file_with_no_relevant_traits }
        let!(:genotype_data_file) { csv_genotype_data_file }

        it "fails" do
          expect { subject.call }.
            to change { analysis.reload.status }.
            from("idle").to("failure")

          expect(analysis.meta).to include('failure_reason' => "all_traits_removed")
        end
      end
    end

    context "plant trial based analysis" do
      let!(:plant_trial) { create(:plant_trial, user: analysis.owner) }
      let!(:trait_descriptors) { create_list(:trait_descriptor, 5) }
      let!(:plant_scoring_units) {
        1.upto(100).map { |idx|
          create(:plant_scoring_unit, plant_trial: plant_trial, scoring_unit_name: "plant-#{idx}")
        }
      }

      let!(:genotype_data_file) { vcf_genotype_data_file }

      let(:runner) { double(call: nil, results_dir: nil, store_result: nil) }

      before do
        analysis.update!(meta: { plant_trial_id: plant_trial.id })
      end

      context "PT with relevant trait scores" do
        let!(:trait_scores) {
          plant_scoring_units.map.with_index { |psu, idx|
            trait_descriptor = trait_descriptors.sample
            score_value = trait_descriptor == trait_descriptors.first ? 0 : idx

            create(:trait_score, plant_scoring_unit: psu, score_value: score_value, trait_descriptor: trait_descriptor)
          }
        }

        it "creates phenotype CSV from plant trial data" do
          expect { subject.call }.
            to change { analysis.data_files.gwas_phenotype.count }.
            from(0).to(1)
        end

        it "runs successfully" do
          expect { subject.call }.
            to change { analysis.reload.status }.
            from("idle").to("success")

          expect(analysis.meta).to include('removed_mutations' => %w(snp-4_G_C))
          expect(analysis.meta).to include('removed_traits' => [trait_descriptors.first.trait_name])
        end
      end

      context "PT with non-relevant trait scores" do
        let!(:trait_scores) {
          plant_scoring_units.map.with_index { |psu, idx|
            trait_descriptor = trait_descriptors.sample
            score_value = 0

            create(:trait_score, plant_scoring_unit: psu, score_value: score_value, trait_descriptor: trait_descriptor)
          }
        }

        it "fails" do
          expect { subject.call }.
            to change { analysis.reload.status }.
            from("idle").to("failure")

          expect(analysis.meta).to include('failure_reason' => "all_traits_removed")
        end
      end
    end
  end
end
