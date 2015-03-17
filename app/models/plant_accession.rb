class PlantAccession < ActiveRecord::Base
  self.primary_key = 'plant_accession'

  belongs_to :plant_line, foreign_key: 'plant_line_name'

  has_many :plant_scoring_units, foreign_key: 'plant_accession'

end