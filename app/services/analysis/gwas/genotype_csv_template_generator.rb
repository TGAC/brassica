class Analysis
  class Gwas
    class GenotypeCsvTemplateGenerator
      def initialize(plant_trial = nil)
        @plant_trial = plant_trial
      end

      def call
        values = [0, 1, 2, "NA"]
        snps = ["SNP-1", "SNP-2", "SNP-3", "SNP-4"]

        CSV.generate do |csv|
          csv << ["ID"] + sample_ids

          snps.each do |snp|
            csv << [snp] + values.shuffle
          end
        end
      end

      private

      def sample_ids
        if @plant_trial
          @plant_trial.plant_scoring_units.order(:scoring_unit_name).pluck(:scoring_unit_name)
        else
          %w(Plant-sample-id-1 Plant-sample-id-2 Plant-sample-id-3)
        end
      end
    end
  end
end
