class PlantVariety < ActiveRecord::Base

  has_and_belongs_to_many :countries_of_origin,
                          class_name: 'Country',
                          join_table: 'plant_variety_country_of_origin'

  has_and_belongs_to_many :countries_registered,
                          class_name: 'Country',
                          join_table: 'plant_variety_country_registered'

  has_many :plant_lines

end