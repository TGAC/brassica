class AddLayoutToPlantTrials < ActiveRecord::Migration
  def up
    add_attachment :plant_trials, :layout
  end

  def down
    remove_attachment :plant_trials, :layout
  end
end
