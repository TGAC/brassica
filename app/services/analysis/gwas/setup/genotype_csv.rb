class Analysis
  class Gwas
    class Setup
      class GenotypeCsv
        include Helpers

        def initialize(analysis)
          @analysis = analysis
        end

        def applicable?
          genotype_data_file(:csv).try(:uploaded?)
        end

        def call
          save_mutations_to_remove

          geno_status, geno_csv_file = normalize_geno_csv

          check_geno_status(geno_status).tap do |status|
            create_csv_data_file(geno_csv_file, data_type: :gwas_genotype) if status == :ok
          end
        end

        private

        attr_accessor :analysis

        def save_mutations_to_remove
          mutations = find_csv_columns_to_remove(genotype_data_file(:csv).file)

          analysis.meta['removed_mutations'] = mutations
          analysis.save!
        end

        def normalize_geno_csv
          normalize_csv(genotype_data_file(:csv).file, remove_columns: analysis.meta['removed_mutations'])
        end

        def check_geno_status(status)
          case status
          when :ok then :ok
          when :all_columns_removed then :all_mutations_removed
          else fail "Invalid status: #{status}"
          end
        end
      end
    end
  end
end
