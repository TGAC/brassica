class PlantPopulationList < ActiveRecord::Base

  belongs_to :plant_line
  belongs_to :plant_population, counter_cache: true

  include Annotable

  validates :sort_order,
            presence: true
end