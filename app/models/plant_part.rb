class PlantPart < ActiveRecord::Base

  has_many :plant_scoring_units

  include Annotable

  validates :plant_part,
            presence: true
end
