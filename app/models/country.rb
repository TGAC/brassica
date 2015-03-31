class Country < ActiveRecord::Base

  has_and_belongs_to_many :originating_plant_varieties,
                          class_name: 'PlantVariety',
                          join_table: 'plant_variety_country_of_origin',
                          foreign_key: 'country_code',
                          association_foreign_key: 'plant_variety_name'

  has_and_belongs_to_many :registered_plant_varieties,
                          class_name: 'PlantVariety',
                          join_table: 'plant_variety_country_registered',
                          foreign_key: 'country_code',
                          association_foreign_key: 'plant_variety_name'

  has_many :plant_trials, foreign_key: 'country'
end
