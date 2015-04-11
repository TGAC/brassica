class MarkerSequenceAssignment < ActiveRecord::Base

  has_many :marker_assays

  include Annotable
end
