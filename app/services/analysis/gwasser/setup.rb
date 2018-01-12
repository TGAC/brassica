class Analysis
  class Gwasser
    class Setup
      include Helpers

      def initialize(analysis)
        @analysis = analysis
      end

      def call
        strategies = [
          Analysis::Gwasser::Setup::GenotypeCsv.new(@analysis),
          Analysis::Gwasser::Setup::MapCsv.new(@analysis),
          Analysis::Gwasser::Setup::GenotypeHapmap.new(@analysis),
          Analysis::Gwasser::Setup::GenotypeVcf.new(@analysis),
          Analysis::Gwasser::Setup::PhenotypePlantTrial.new(@analysis),
          Analysis::Gwasser::Setup::PhenotypeCsv.new(@analysis),
          Analysis::Gwas::Setup::StripGenotypeCsv.new(@analysis),
          Analysis::Gwas::Setup::StripPhenotypeCsv.new(@analysis)
        ]

        strategies.select(&:applicable?).each do |strategy|
          status = strategy.call
          return status unless status == :ok
        end

        :ok
      end
    end
  end
end
