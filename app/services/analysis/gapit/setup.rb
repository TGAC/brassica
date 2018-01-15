class Analysis
  class Gapit
    class Setup
      def initialize(analysis)
        @analysis = analysis
      end

      def call
        strategies = [
          Analysis::Gwas::Setup::GenotypeCsv.new(@analysis),
          Analysis::Gwas::Setup::MapCsv.new(@analysis),
          Analysis::Gwas::Setup::GenotypeVcf.new(@analysis),
          Analysis::Gwas::Setup::PhenotypePlantTrial.new(@analysis),
          Analysis::Gwas::Setup::PhenotypeCsv.new(@analysis),
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
