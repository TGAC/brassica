class DesignFactor < ActiveRecord::Base

  COMMON_NAMES = %w(location room polytunnel greenhouse occasion treatment
                    bench rep area-pair block sub-block row col plot pot)

  has_many :plant_scoring_units

  validates :design_unit_counter, presence: true

  include Annotable
end
