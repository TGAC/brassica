class PlantPopulationList < ActiveRecord::Base

  belongs_to :plant_line, foreign_key: 'plant_line_name'
  belongs_to :plant_population

end