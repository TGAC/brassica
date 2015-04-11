class LinkageMap < ActiveRecord::Base

  has_and_belongs_to_many :linkage_groups,
                          join_table: 'map_linkage_group_lists'

  belongs_to :plant_population

  has_many :map_linkage_group_lists

  has_many :genotype_matrices, foreign_key: 'linkage_map_id'

  has_many :map_locus_hits, foreign_key: 'linkage_map_id'

  include Pluckable

  def self.table_data(params = nil)
    pluck_columns(table_columns)
  end

  def self.table_columns
    [
      'plant_populations.taxonomy_terms.name',
      'linkage_map_label',
      'linkage_map_name',
      'plant_populations.name',
      'map_version_no',
      'map_version_date'
    ]
  end

  include Annotable
end
