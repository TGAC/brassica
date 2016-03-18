class PlantPart < ActiveRecord::Base
  include ActiveModel::Validations

  has_many :plant_scoring_units

  validates :plant_part,
            presence: true,
            uniqueness: true

  validates_with PublicationValidator

  include Annotable
end
