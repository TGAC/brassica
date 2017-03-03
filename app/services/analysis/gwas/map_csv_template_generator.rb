class Analysis
  class Gwas
    class MapCsvTemplateGenerator
      def call
        CSV.generate do |csv|
          csv << ["ID",     "Chr",  "cM"]
          csv << ["SNP 1",  "C01",  0.01]
          csv << ["SNP 2",  "C01",  0.12]
          csv << ["SNP 3",  "C02",  1.11]
          csv << ["SNP4",   "C02",  4.12]
        end
      end
    end
  end
end
