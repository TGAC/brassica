class DesignFactor < ActiveRecord::Base

  COMMON_NAMES = %w(field polytunnel rep block pot plot occassion)

  has_many :plant_scoring_units

  validates :design_unit_counter, presence: true

  include Annotable
end
