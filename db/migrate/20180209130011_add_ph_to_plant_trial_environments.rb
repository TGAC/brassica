class AddPhToPlantTrialEnvironments < ActiveRecord::Migration
  def change
    add_column :plant_trial_environments, :ph, :string
  end
end
