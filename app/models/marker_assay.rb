class MarkerAssay < ActiveRecord::Base

  belongs_to :marker_sequence_assignment

  belongs_to :restriction_enzyme_a, class_name: 'RestrictionEnzyme',
              foreign_key: 'restriction_enzyme_a_id'
  belongs_to :restriction_enzyme_b, class_name: 'RestrictionEnzyme',
              foreign_key: 'restriction_enzyme_b_id'

  belongs_to :primer_a, class_name: 'Primer',
             foreign_key: 'primer_a_id'
  belongs_to :primer_b, class_name: 'Primer',
             foreign_key: 'primer_b_id'

  belongs_to :probe

  has_many :population_loci

  include Annotable
end
