class Analysis
  module Gwas
    module Setup
      class GenotypeHapmapMetadata
        include Gwas::Helpers

        def initialize(analysis)
          @analysis = analysis
        end

        def applicable?
          genotype_data_file(:hapmap).present? && !map_data_file.present?
        end

        def call
          samples, chromosomes = analyze_geno_hapmap_file
          save_genotype_metadata(samples: samples, chromosomes: chromosomes)

          :ok
        end

        private

        attr_accessor :analysis

        def analyze_geno_hapmap_file
          Analysis::Gwas::GenotypeHapmapMetadataAnalyzer.new.call(genotype_data_file(:hapmap).file.path)
        end
      end
    end
  end
end
