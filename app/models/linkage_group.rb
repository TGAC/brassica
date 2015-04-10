class LinkageGroup < ActiveRecord::Base

  has_and_belongs_to_many :linkage_maps,
                          join_table: 'map_linkage_group_lists'

  has_many :map_linkage_group_lists

  has_many :map_positions

  has_many :map_locus_hits

  has_many :qtls

  include Annotable
end
