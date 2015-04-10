class ScoringOccasion < ActiveRecord::Base

  has_many :trait_scores

  include Annotable
end
