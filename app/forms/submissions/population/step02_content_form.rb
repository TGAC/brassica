module Submissions
  module Population
    class Step02ContentForm < PlantPopulationForm
      property :population_type
      property :taxonomy_term

      validates :taxonomy_term, inclusion: { in: :taxonomy_term_names }
      validates :population_type, inclusion: { in: :population_types }

      def taxonomy_term_names
        TaxonomyTerm.names
      end

      def population_types
        PopulationType.population_types
      end
    end
  end
end
