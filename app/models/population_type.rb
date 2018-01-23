class PopulationType < ApplicationRecord
  self.table_name = 'pop_type_lookup'

  has_many :plant_populations

  validates :population_type,
            presence: true

  validates :population_class,
            presence: true

  include Filterable

  def self.population_types
    order(:population_type).pluck(:population_type)
  end

  def self.permitted_params
    [
      query: [
        'id'
      ]
    ]
  end
end
