module Submissions
  module Trial
    class Step01ContentForm < PlantTrialForm
      property :plant_trial_name
      property :project_descriptor

      validates :plant_trial_name, presence: true

      validate do
        if PlantTrial.where(plant_trial_name: plant_trial_name).exists?
          errors.add(:plant_trial_name, :taken)
        end
      end
    end
  end
end
