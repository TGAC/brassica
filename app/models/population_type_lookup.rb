class PopulationTypeLookup < ActiveRecord::Base
  self.table_name = 'pop_type_lookup'

  has_many :plant_populations, foreign_key: 'population_type'

end