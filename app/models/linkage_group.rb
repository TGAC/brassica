class LinkageGroup < ActiveRecord::Base

  has_and_belongs_to_many :linkage_maps,
                          join_table: 'map_linkage_group_lists',
                          foreign_key: 'linkage_group_id'

  has_many :map_positions

  has_many :map_locus_hits, foreign_key: 'linkage_group_id'

  has_many :qtls

end
