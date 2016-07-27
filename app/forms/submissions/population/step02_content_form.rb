module Submissions
  module Population
    class Step02ContentForm < PlantPopulationForm
      property :population_type
      property :taxonomy_term

      validates :population_type, inclusion: { in: :population_types }

      def population_types
        PopulationType.population_types
      end
    end
  end
end
