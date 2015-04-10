class DesignFactor < ActiveRecord::Base

  has_many :plant_scoring_units

  include Annotable
end
