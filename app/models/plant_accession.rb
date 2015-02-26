class PlantAccession < ActiveRecord::Base

  belongs_to :plant_line, foreign_key: 'plant_line_name'

end