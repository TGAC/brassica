class PlantPopulationList < ActiveRecord::Base

  belongs_to :plant_line
  belongs_to :plant_population, counter_cache: true
  belongs_to :user

  def published?
    updated_at < Time.now - 1.week
  end

  include Annotable
end