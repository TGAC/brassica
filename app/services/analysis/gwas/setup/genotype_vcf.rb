class Analysis
  module Gwas
    module Setup
      class GenotypeVcf
        include Gwas::Helpers

        def initialize(analysis)
          @analysis = analysis
        end

        def applicable?
          genotype_data_file(:vcf).present?
        end

        def call
          status, geno_csv_file, map_csv_file, removed_mutations, samples =
            convert_genotype_vcf_to_csv

          if status == :ok
            create_csv_data_file(geno_csv_file, data_type: :gwas_genotype)
            create_csv_data_file(map_csv_file, data_type: :gwas_map)

            save_genotype_metadata(removed_mutations, samples)
          end

          status
        end

        private

        attr_accessor :analysis

        def convert_genotype_vcf_to_csv
          # NOTE: no need to normalize as conversion already outputs correct files
          Analysis::Gwasser::GenotypeVcfToCsvConverter.new.call(genotype_data_file(:vcf).file.path)
        end
      end
    end
  end
end
