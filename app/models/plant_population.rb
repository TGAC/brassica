class PlantPopulation < ActiveRecord::Base

  belongs_to :population_type_lookup, foreign_key: 'population_type'

  belongs_to :male_parent_line, class_name: 'PlantLine',
             foreign_key: 'male_parent_line'

  belongs_to :female_parent_line, class_name: 'PlantLine',
             foreign_key: 'female_parent_line'

  has_many :plant_population_lists, foreign_key: 'plant_population_id'

  has_and_belongs_to_many :plant_lines,
                          join_table: 'plant_population_lists',
                          association_foreign_key: 'plant_line_name'

end