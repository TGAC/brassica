class DesignFactor < ActiveRecord::Base

  has_many :plant_scoring_units

  include Annotable

  validates :design_factor_name,
            presence: true

  validates :institute_id,
            presence: true

  validates :trial_location_name,
            presence: true

  validates :design_unit_counter,
            presence: true
end
