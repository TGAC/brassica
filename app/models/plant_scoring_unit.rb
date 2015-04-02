class PlantScoringUnit < ActiveRecord::Base

  belongs_to :design_factor
  belongs_to :plant_trial
  belongs_to :plant_accession
  belongs_to :plant_part, foreign_key: 'scored_plant_part'

  has_many :trait_scores, foreign_key: 'scoring_unit_id'

end
