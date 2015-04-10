class PopulationType < ActiveRecord::Base
  self.table_name = 'pop_type_lookup'

  has_many :plant_populations

  def self.population_types
    order(:population_type).pluck(:population_type)
  end
end
