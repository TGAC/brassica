require "csv"

class Analysis
  class GenotypeHapmapMetadataAnalyzer
    def call(path)
      File.open(path, "r") do |hapmap_file|
        hapmap_data = Analysis::GenotypeHapmapParser.new.call(hapmap_file)
        chromosomes = Set.new

        raise unless hapmap_data.valid?

        hapmap_data.each_record do |record|
          chromosomes << record.chrom
        end

        [hapmap_data.sample_ids, chromosomes.to_a]
      end
    end
  end
end
