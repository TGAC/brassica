class TraitScore < ActiveRecord::Base

  belongs_to :plant_scoring_unit, foreign_key: 'scoring_unit_id'
  belongs_to :scoring_occasion
  belongs_to :trait_descriptor

end
