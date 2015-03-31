class PlantPopulationList < ActiveRecord::Base

  belongs_to :plant_line
  belongs_to :plant_population

end