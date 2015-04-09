class MapLocusHit < ActiveRecord::Base

  belongs_to :linkage_map
  belongs_to :linkage_group
  belongs_to :map_position, foreign_key: 'map_position'
  belongs_to :population_locus

end
