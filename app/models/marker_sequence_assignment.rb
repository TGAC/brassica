class MarkerSequenceAssignment < ActiveRecord::Base

  has_many :marker_assays

  include Annotable

  validates :marker_set,
            presence: true

  validates :canonical_marker_name,
            presence: true
end
