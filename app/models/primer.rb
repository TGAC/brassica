class Primer < ActiveRecord::Base

  has_many :marker_assays_A, class_name: 'MarkerAssay',
             foreign_key: 'primer_a'
  has_many :marker_assays_B, class_name: 'MarkerAssay',
           foreign_key: 'primer_b'

end
