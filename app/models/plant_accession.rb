class PlantAccession < ActiveRecord::Base

  belongs_to :plant_line

  has_many :plant_scoring_units

  validates :plant_accession,
            presence: true

  validates :year_produced,
            presence: true,
            length: {is: 4}

  include Annotable
end
