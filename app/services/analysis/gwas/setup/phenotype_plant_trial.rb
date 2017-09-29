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
          pheno_csv_file, trait_names = Analysis::Gwas::PlantTrialPhenotypeCsvBuilder.new.build_csv(plant_trial)

          traits_to_remove = save_traits_to_remove(pheno_csv_file)

          return :all_traits_removed if traits_to_remove && trait_names.size == traits_to_remove.size

          _, pheno_csv_file = normalize_pheno_csv(pheno_csv_file) if traits_to_remove.present?

          create_csv_data_file(pheno_csv_file, data_type: :gwas_phenotype)

          :ok
        end

        private

        attr_accessor :analysis
      end
    end
  end
end
