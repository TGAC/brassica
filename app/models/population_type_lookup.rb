class PopulationTypeLookup < ActiveRecord::Base
  self.table_name = 'pop_type_lookup'
  self.primary_key = 'population_type'

  has_many :plant_populations, foreign_key: 'population_type'

  def self.population_types
    order(:population_type).pluck(:population_type)
  end
end
