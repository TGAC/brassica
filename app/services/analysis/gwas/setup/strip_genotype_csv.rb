class Analysis
  class Gwas
    class Setup
      class StripGenotypeCsv
        include Helpers

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

          check_geno_status(geno_status).tap do |status|
            if status == :ok
              genotype_data_file(:csv).destroy
              create_csv_data_file(geno_csv_file, data_type: :gwas_genotype)
            end
          end
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
          when :all_rows_removed then :all_samples_removed
          else fail "Invalid status: #{status}"
          end
        end
      end
    end
  end
end
