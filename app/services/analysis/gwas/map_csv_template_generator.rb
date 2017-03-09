class Analysis
  class Gwas
    class MapCsvTemplateGenerator
      def call
        CSV.generate do |csv|
          csv << ["ID",     "Chr",  "cM"]
          csv << ["SNP 1",  "1",  0.01]
          csv << ["SNP 2",  "1",  0.12]
          csv << ["SNP 3",  "2",  1.11]
          csv << ["SNP4",   "2",  4.12]
        end
      end
    end
  end
end
