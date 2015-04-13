class PlantAccession < ActiveRecord::Base

  belongs_to :plant_line

  has_many :plant_scoring_units

  include Annotable
end