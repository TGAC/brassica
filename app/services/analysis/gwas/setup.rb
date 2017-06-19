class Analysis
  class Gwas
    class Setup
      include Helpers

      def initialize(analysis)
        @analysis = analysis
      end

      # TODO: do not generate normalized files if it is not necessary
      def call
        strategies = [
          Analysis::Gwas::Setup::GenotypeCsv.new(@analysis),
          Analysis::Gwas::Setup::MapCsv.new(@analysis),
          Analysis::Gwas::Setup::GenotypeVcf.new(@analysis),
          Analysis::Gwas::Setup::PhenotypePlantTrial.new(@analysis),
          Analysis::Gwas::Setup::PhenotypeCsv.new(@analysis)
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
