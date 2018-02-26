class Analysis
  module Gwas
    module Setup
      class StripGenotypeCsv
        include Gwas::Helpers

        def initialize(analysis)
          @analysis = analysis
        end

        def applicable?
          true
        end

        def call
          return :all_samples_removed if common_samples.empty?
          return :ok if (analysis.meta['geno_samples'] - common_samples).empty?

          geno_status, geno_csv_file = strip_geno_csv

          if geno_status == :ok
            genotype_data_file(:csv).destroy
            create_csv_data_file(geno_csv_file, data_type: :gwas_genotype)

            geno_status = remove_irrelevant_mutations
          end

          check_geno_status(geno_status)
        end

        private

        attr_accessor :analysis

        def common_samples
          @common_samples ||= analysis.meta['geno_samples'] & analysis.meta['pheno_samples']
        end

        def strip_geno_csv
          normalize_csv(genotype_data_file(:csv).file, remove_rows: analysis.meta['geno_samples'] - common_samples)
        end

        def check_geno_status(status)
          case status
          when :ok then :ok
          when :all_columns_removed then :all_mutations_removed
          when :all_rows_removed then :all_samples_removed
          else fail "Invalid status: #{status}"
          end
        end

        def remove_irrelevant_mutations
          analyze_geno_csv_file do |mutations_to_remove, _|
            append_genotype_metadata(removed_mutations: mutations_to_remove)
          end

          geno_status, geno_csv_file = normalize_geno_csv

          if geno_status == :ok
            genotype_data_file(:csv).destroy
            create_csv_data_file(geno_csv_file, data_type: :gwas_genotype)
          end

          geno_status
        end
      end
    end
  end
end
