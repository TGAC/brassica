class MarkerSequenceAssignment < ActiveRecord::Base
  include ActiveModel::Validations

  has_many :marker_assays

  validates :marker_set,
            presence: true

  validates :canonical_marker_name,
            presence: true

  validates_with PublicationValidator

  include Annotable
end
