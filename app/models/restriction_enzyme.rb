class RestrictionEnzyme < ActiveRecord::Base
  include ActiveModel::Validations

  has_many :marker_assays_a, class_name: 'MarkerAssay',
             foreign_key: 'restriction_enzyme_a_id'
  has_many :marker_assays_b, class_name: 'MarkerAssay',
             foreign_key: 'restriction_enzyme_b_id'

  validates :restriction_enzyme,
            presence: true,
            uniqueness: true

  validates :recognition_site,
            presence: true

  validates_with PublicationValidator

end
