class PlantVariety < ActiveRecord::Base

  has_many :plant_variety_details, foreign_key: 'plant_variety_name'

end