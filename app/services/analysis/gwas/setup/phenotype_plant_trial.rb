class Analysis
  class Gwas
    class Setup
      class PhenotypePlantTrial
        include Helpers

        def initialize(analysis)
          @analysis = analysis
        end

        def applicable?
          analysis.plant_trial_based?
        end

        def call
          plant_trial = PlantTrial.visible(analysis.owner_id).find(analysis.meta.fetch("plant_trial_id"))
          phenotype_csv = Analysis::Gwas::PlantTrialPhenotypeCsvBuilder.new.build_csv(plant_trial)

          # TODO: make sure that trait data has enough variance

          create_csv_data_file(phenotype_csv, data_type: :gwas_phenotype)

          :ok
        end

        private

        attr_accessor :analysis
      end
    end
  end
end
