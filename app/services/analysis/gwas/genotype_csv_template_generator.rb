class Analysis
  class Gwas
    class GenotypeCsvTemplateGenerator
      def call
        CSV.generate do |csv|
          csv << ["ID",       "SNP 1",  "SNP 2",  "SNP 3",  "SNP4"]
          csv << ["Plant 1",  "NA",     0,         1,       2]
          csv << ["Plant 2",  "NA",     0,         1,       2]
          csv << ["Plant 3",  "NA",     0,         1,       2]
        end
      end
    end
  end
end
