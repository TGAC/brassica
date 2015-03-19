class PlantVarietyDetail < ActiveRecord::Base
  self.table_name = 'plant_variety_detail'
  self.primary_key = 'plant_variety_name'

  belongs_to :plant_variety, foreign_key: 'plant_variety_name'

end