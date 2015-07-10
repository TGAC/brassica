module Submissions
  module Population
    class Step01ContentForm < PlantPopulationForm
      property :name
      property :description
      property :owned_by

      validates :name, presence: true

      validate do
        if PlantPopulation.where(name: name).exists?
          errors.add(:name, :taken)
        end
      end
    end
  end
end
