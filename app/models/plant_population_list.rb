class PlantPopulationList < ActiveRecord::Base

  belongs_to :plant_line
  belongs_to :plant_population, counter_cache: true
  belongs_to :user

  validates :plant_line_id,
            presence: true

  validates :plant_population_id,
            presence: true

  def published?
    updated_at < Time.now - 1.week
  end

  include Annotable
end