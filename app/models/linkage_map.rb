class LinkageMap < ActiveRecord::Base

  has_and_belongs_to_many :linkage_groups,
                          join_table: 'map_linkage_group_lists'

  belongs_to :plant_population

  has_many :map_linkage_group_lists

  has_many :genotype_matrices, foreign_key: 'linkage_map_id'

  has_many :map_locus_hits, foreign_key: 'linkage_map_id'

end
