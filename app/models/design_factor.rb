class DesignFactor < ActiveRecord::Base
  has_many :plant_scoring_units

  validates :design_unit_counter, presence: true

  include Annotable
end
