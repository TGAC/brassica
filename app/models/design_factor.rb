class DesignFactor < ActiveRecord::Base
  belongs_to :user

  after_update { plant_scoring_units.each(&:touch) }
  before_destroy { plant_scoring_units.each(&:touch) }

  has_many :plant_scoring_units

  validates :design_factors, presence: true

  validates :design_factor_name,
            presence: true,
            uniqueness: true

  validates :institute_id,
            presence: true

  validates :trial_location_name,
            presence: true

  validates :design_unit_counter,
            presence: true

  include Publishable

  include Annotable
end
