class Analysis
  class Gwas
    class Setup
      class GenotypeVcf
        include Helpers

        def initialize(analysis)
          @analysis = analysis
        end

        def applicable?
          genotype_data_file(:vcf).present?
        end

        def call
          status, geno_csv_file, map_csv_file, removed_mutations =
            convert_genotype_vcf_to_csv

          if status == :ok
            create_csv_data_file(geno_csv_file, data_type: :gwas_genotype)
            create_csv_data_file(map_csv_file, data_type: :gwas_map)
            save_removed_mutations(removed_mutations)
          end

          status
        end

        private

        attr_accessor :analysis

        def convert_genotype_vcf_to_csv
          # NOTE: no need to normalize as conversion already outputs correct files
          Analysis::Gwas::GenotypeVcfToCsvConverter.new.call(genotype_data_file(:vcf).file.path)
        end

        def save_removed_mutations(mutations)
          analysis.meta['removed_mutations'] = mutations
          analysis.save!
        end
      end
    end
  end
end
