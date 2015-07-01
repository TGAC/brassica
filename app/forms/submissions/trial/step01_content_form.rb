module Submissions
  module Trial
    class Step01ContentForm < PlantTrialForm
      property :plant_trial_name
      property :project_descriptor
      property :plant_population_id

      validates :plant_trial_name, presence: true
      validates :project_descriptor, presence: true
      validates :plant_population_id, presence: true

      validate do
        if PlantTrial.where(plant_trial_name: plant_trial_name).exists?
          errors.add(:plant_trial_name, :taken)
        end
      end

      def plant_population
        return unless plant_population_id.present?
        PlantPopulation.find_by(id: plant_population_id)
      end
    end
  end
end
