class PlantPopulationList < ActiveRecord::Base

  belongs_to :plant_line
  belongs_to :plant_population, counter_cache: true

  validates :sort_order,
            presence: true

  include Annotable
end