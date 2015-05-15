class DesignFactor < ActiveRecord::Base

  has_many :plant_scoring_units

  validates :design_factor_name,
            presence: true,
            uniqueness: true

  validates :institute_id,
            presence: true

  validates :trial_location_name,
            presence: true

  validates :design_unit_counter,
            presence: true

  include Annotable
end
