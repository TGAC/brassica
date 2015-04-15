class Primer < ActiveRecord::Base

  has_many :marker_assays_a, class_name: 'MarkerAssay',
             foreign_key: 'primer_a_id'
  has_many :marker_assays_b, class_name: 'MarkerAssay',
             foreign_key: 'primer_b_id'

  include Annotable

  validates :primer,
            presence: true

  validates :sequence,
            presence: true

  validates :sequence_id,
            presence: true

  validates :sequence_source_acronym,
            presence: true

  def marker_assays
    marker_assays_a | marker_assays_b
  end
end
