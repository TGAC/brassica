class Analysis
  class Gwas
    class GenotypeCsvTemplateGenerator
      def call
        CSV.generate do |csv|
          csv << ["ID",                 "SNP-1",  "SNP-2",  "SNP-3",  "SNP-4"]
          csv << ["Plant-sample-id-1",  1,        "NA",      1,       2]
          csv << ["Plant-sample-id-2",  0,        1,         1,       0]
          csv << ["Plant-sample-id-3",  "NA",     0,         1,       2]
        end
      end
    end
  end
end
