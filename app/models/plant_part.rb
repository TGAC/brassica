class PlantPart < ActiveRecord::Base
  has_many :plant_scoring_units

  validates :plant_part,
            presence: true,
            uniqueness: true

  include Annotable
end
