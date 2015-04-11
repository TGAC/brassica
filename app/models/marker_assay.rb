class MarkerAssay < ActiveRecord::Base

  belongs_to :marker_sequence_assignment

  belongs_to :restriction_enzyme_A, class_name: 'RestrictionEnzyme',
              foreign_key: 'restriction_enzyme_a_id'
  belongs_to :restriction_enzyme_B, class_name: 'RestrictionEnzyme',
              foreign_key: 'restriction_enzyme_b_id'

  belongs_to :primer_A, class_name: 'Primer',
             foreign_key: 'primer_a_id'
  belongs_to :primer_B, class_name: 'Primer',
             foreign_key: 'primer_b_id'

  belongs_to :probe

  has_many :population_loci, class_name: 'PopulationLocus'

  include Annotable
end
