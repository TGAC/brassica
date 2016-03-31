class FixPlantLinesGeneticStatus < ActiveRecord::Migration
  def up
    execute("UPDATE plant_lines SET genetic_status = 'Open Pollinated' WHERE genetic_status = 'Open Polinated'")
  end

end
