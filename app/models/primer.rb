class Primer < ActiveRecord::Base

  has_many :marker_assays_A, class_name: 'MarkerAssay',
             foreign_key: 'primer_a_id'
  has_many :marker_assays_B, class_name: 'MarkerAssay',
             foreign_key: 'primer_b_id'

  def marker_assays
    marker_assays_A | marker_assays_B
  end

  include Annotable
end
