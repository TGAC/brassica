class MarkerSequenceAssignment < ActiveRecord::Base

  has_many :marker_assays, foreign_key: 'canonical_marker_name'

end
