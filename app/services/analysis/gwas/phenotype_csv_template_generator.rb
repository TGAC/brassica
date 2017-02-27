class Analysis
  class Gwas
    class PhenotypeCsvTemplateGenerator
      def call
        CSV.generate do |csv|
          csv << ["ID",       "Trait 1",  "Trait 2",  "Trait 3"]
          csv << ["Plant 1",  0.125,      "A",        5]
          csv << ["Plant 2",  0.025,      "B",        10]
          csv << ["Plant 3",  0.0,        "C",        7]
        end
      end
    end
  end
end
