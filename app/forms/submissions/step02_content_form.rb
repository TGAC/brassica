module Submissions
  class Step02ContentForm < PlantPopulationForm
    property :population_type
    property :taxonomy_term

    validates :taxonomy_term, inclusion: { in: TaxonomyTerm.names }
    validates :population_type, inclusion: { in: PopulationType.population_types }
  end
end
