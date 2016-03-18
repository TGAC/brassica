class PopulationType < ActiveRecord::Base
  include ActiveModel::Validations
  self.table_name = 'pop_type_lookup'

  has_many :plant_populations

  validates :population_type,
            presence: true

  validates :population_class,
            presence: true

  validates_with PublicationValidator

  def self.population_types
    order(:population_type).pluck(:population_type)
  end
end
