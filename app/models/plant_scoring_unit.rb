class PlantScoringUnit < ActiveRecord::Base

  belongs_to :design_factor
  belongs_to :plant_trial
  belongs_to :plant_accession
  belongs_to :plant_part

  has_many :trait_scores

  validates :scoring_unit_name,
            presence: true

  include Annotable
end
