class PlantScoringUnit < ActiveRecord::Base

  belongs_to :design_factor
  belongs_to :plant_trial
  belongs_to :plant_accession, foreign_key: 'plant_accession'

  has_many :trait_scores, foreign_key: 'scoring_unit_id'

end
