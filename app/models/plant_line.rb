class PlantLine < ActiveRecord::Base

  belongs_to :plant_variety, foreign_key: 'plant_variety_name'

  has_many :plant_population_lists, foreign_key: 'plant_line_name'

  has_many :plant_accessions, foreign_key: 'plant_line_name'

  has_and_belongs_to_many :plant_populations,
                          join_table: 'plant_population_lists',
                          foreign_key: 'plant_line_name',
                          association_foreign_key: 'plant_population_id'

end