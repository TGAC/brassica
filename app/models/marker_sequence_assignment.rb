class MarkerSequenceAssignment < ApplicationRecord
  has_many :marker_assays

  validates :marker_set,
            presence: true

  validates :canonical_marker_name,
            presence: true

  include Annotable
end
