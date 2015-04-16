class TraitScore < ActiveRecord::Base

  belongs_to :plant_scoring_unit
  belongs_to :scoring_occasion
  belongs_to :trait_descriptor, counter_cache: true

  validates :scoring_occasion_name,
            presence: true

  include Annotable
end
