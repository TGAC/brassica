class PlantPart < ActiveRecord::Base

  has_many :plant_scoring_units, foreign_key: 'scored_plant_part'

end
