class MapLocusHit < ActiveRecord::Base

  belongs_to :linkage_map, foreign_key: 'linkage_map_id'
  belongs_to :linkage_group, foreign_key: 'linkage_group_id'
  belongs_to :map_position, foreign_key: 'map_position'
  belongs_to :population_locus, foreign_key: 'mapping_locus'

end
