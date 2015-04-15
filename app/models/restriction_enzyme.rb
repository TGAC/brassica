class RestrictionEnzyme < ActiveRecord::Base

  has_many :marker_assays_a, class_name: 'MarkerAssay',
             foreign_key: 'restriction_enzyme_a_id'
  has_many :marker_assays_b, class_name: 'MarkerAssay',
             foreign_key: 'restriction_enzyme_b_id'

  validates :restriction_enzyme,
            presence: true

  validates :recognition_site,
            presence: true

  validates :data_provenance,
            presence: true
end
