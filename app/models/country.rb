class Country < ActiveRecord::Base

  has_and_belongs_to_many :originating_plant_varieties,
                          class_name: 'PlantVariety',
                          join_table: 'plant_variety_country_of_origin'

  has_and_belongs_to_many :registered_plant_varieties,
                          class_name: 'PlantVariety',
                          join_table: 'plant_variety_country_registered'

  has_many :plant_trials, foreign_key: 'country'
end
