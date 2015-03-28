class PlantLineDetail < ActiveRecord::Base
  self.primary_key = 'plant_variety_name'

  has_many :plant_lines, foreign_key: 'plant_variety_name'

end