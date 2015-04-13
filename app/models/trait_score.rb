class TraitScore < ActiveRecord::Base

  belongs_to :plant_scoring_unit
  belongs_to :scoring_occasion
  belongs_to :trait_descriptor, counter_cache: true

  include Annotable
end
