class Analysis
  module Gwas
    module Setup
      class PhenotypeCsv
        include Gwas::Helpers

        def initialize(analysis)
          @analysis = analysis
        end

        def applicable?
          !analysis.plant_trial_based?
        end

        def call
          analyze_pheno_csv_file

          pheno_status, pheno_csv_file = normalize_pheno_csv

          check_pheno_status(pheno_status).tap do |status|
            create_csv_data_file(pheno_csv_file, data_type: :gwas_phenotype) if status == :ok
          end
        end

        private

        attr_accessor :analysis

        def normalize_pheno_csv
          normalize_csv(phenotype_data_file.file, remove_columns: analysis.meta['removed_traits'])
        end

        def check_pheno_status(status)
          case status
          when :ok then :ok
          when :all_columns_removed then :all_traits_removed
          else fail "Invalid status: #{status}"
          end
        end
      end
    end
  end
end
