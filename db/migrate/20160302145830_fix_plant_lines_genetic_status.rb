class FixPlantLinesGeneticStatus < ActiveRecord::Migration
  def up
    PlantLine.where(genetic_status: 'Open Polinated').each do |open_polinated|
      open_polinated.genetic_status = 'Open Pollinated'
      open_polinated.save!
    end
  end
end
