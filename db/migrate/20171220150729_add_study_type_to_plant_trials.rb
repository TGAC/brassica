class AddStudyTypeToPlantTrials < ActiveRecord::Migration
  def change
    add_column :plant_trials, :study_type, :integer, limit: 2
  end
end
