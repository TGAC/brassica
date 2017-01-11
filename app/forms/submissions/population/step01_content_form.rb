module Submissions
  module Population
    class Step01ContentForm < PlantPopulationForm
      property :name
      property :description
      property :population_type
      property :owned_by

      validates :name, presence: true
      validates :population_type, inclusion: { in: :population_types }

      validate do
        if PlantPopulation.where(name: name).exists?
          errors.add(:name, :taken)
        end
      end

      def population_types
        PopulationType.population_types
      end
    end
  end
end
