class DesignFactor < ActiveRecord::Base
  COMMON_NAMES = %w(location room polytunnel greenhouse occasion treatment
                    bench rep area-pair block sub-block row col plot pot)

  belongs_to :user

  after_update { plant_scoring_units.each(&:touch) }
  before_destroy { plant_scoring_units.each(&:touch) }

  has_many :plant_scoring_units

  validates :design_factors, presence: true
  validates :design_unit_counter, presence: true

  include Publishable
  include Filterable

  def self.permitted_params
    [
      query: [
        'id'
      ]
    ]
  end

  include Annotable
end
