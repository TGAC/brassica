class Analysis
  class Gwas
    class MapCsvTemplateGenerator
      def call
        CSV.generate do |csv|
          csv << ["ID",     "Chr",  "cM"]
          csv << ["SNP-1",  "1",    "1"]
          csv << ["SNP-2",  "1",    "12"]
          csv << ["SNP-3",  "2",    "111"]
          csv << ["SNP-4",  "2",    "112"]
        end
      end
    end
  end
end
