class ScoringOccasion < ActiveRecord::Base

  has_many :trait_scores

  include Annotable

  validates :scoring_occasion_name,
            presence: true
end
