class ScoringOccasion < ActiveRecord::Base

  has_many :trait_scores

  validates :scoring_occasion_name,
            presence: true

  include Annotable
end
