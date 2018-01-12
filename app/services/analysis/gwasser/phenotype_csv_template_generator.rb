class Analysis
  class Gwasser
    class PhenotypeCsvTemplateGenerator
      def call
        CSV.generate do |csv|
          csv << ["ID",                 "Trait-1",  "Trait-2",  "Trait-3", "Trait-4"]
          csv << ["Plant-sample-id-1",  0.125,      "A",        5,         "yes"]
          csv << ["Plant-sample-id-2",  0.025,      "B",        10,        "no"]
          csv << ["Plant-sample-id-3",  0.0,        "C",        7,         "no"]
        end
      end
    end
  end
end
