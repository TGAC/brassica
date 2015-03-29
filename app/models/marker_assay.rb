class MarkerAssay < ActiveRecord::Base

  belongs_to :marker_sequence_assignment, foreign_key: 'canonical_marker_name'

  # belongs_to :restriction_enzyme_A, class_name: 'RestrictionEnzyme',
  #            foreign_key: 'restriction_enzyme_A'
  # belongs_to :restriction_enzyme_B, class_name: 'RestrictionEnzyme',
  #            foreign_key: 'restriction_enzyme_B'

  belongs_to :primer_A, class_name: 'Primer',
             foreign_key: 'primer_a'
  belongs_to :primer_B, class_name: 'Primer',
             foreign_key: 'primer_b'

  belongs_to :probe, foreign_key: 'probe_name'

  has_many :population_loci, class_name: 'PopulationLocus',
           foreign_key: 'marker_assay_name'

end
