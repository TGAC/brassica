module Submissions
  module Population
    class Step01ContentForm < PlantPopulationForm
      property :name
      property :description
      property :establishing_organisation
      property :population_type
      property :owned_by

      validates :name, presence: true
      validates :establishing_organisation, presence: true
      validates :population_type, inclusion: { in: :population_types }

      validate do
        if PlantPopulation.where(name: name).exists?
          errors.add(:name, :taken)
        end
      end

      def establishing_organisations(user)
        PlantPopulation.visible(user.id).attribute_values(:establishing_organisation).delete_if(&:blank?).sort
      end

      def population_types
        PopulationType.population_types
      end
    end
  end
end
