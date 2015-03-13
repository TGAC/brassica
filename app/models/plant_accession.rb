class PlantAccession < ActiveRecord::Base
  self.primary_key = 'plant_accession'

  belongs_to :plant_line, foreign_key: 'plant_line_name'

end