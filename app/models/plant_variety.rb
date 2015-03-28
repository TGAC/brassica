class PlantVariety < ActiveRecord::Base
  self.primary_key = 'plant_variety_name'

  has_and_belongs_to_many :countries_of_origin,
                          class_name: 'Country',
                          join_table: 'plant_variety_country_of_origin',
                          foreign_key: 'plant_variety_name',
                          association_foreign_key: 'country_code'

  has_and_belongs_to_many :countries_registered,
                          class_name: 'Country',
                          join_table: 'plant_variety_country_registered',
                          foreign_key: 'plant_variety_name',
                          association_foreign_key: 'country_code'

  has_many :plant_lines, foreign_key: 'plant_variety_name'

end