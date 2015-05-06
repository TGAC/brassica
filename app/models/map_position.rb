class MapPosition < ActiveRecord::Base

  belongs_to :linkage_group, counter_cache: true

  belongs_to :population_locus, counter_cache: true

  # has_many :map_locus_hits, foreign_key: 'map_position' # PROBLEMATIC, do not use

  validates :marker_assay_name,
            presence: true

  validates :mapping_locus,
            presence: true

  include Filterable
  include Pluckable

  def self.table_data(params = nil)
    query = (params && params[:query].present?) ? filter(params) : all
    query.pluck_columns
  end

  def self.table_columns
    [
      'marker_assay_name',
      'map_position',
      'linkage_groups.linkage_group_label',
      'population_loci.mapping_locus'
    ]
  end

  def self.permitted_params
    [
      query: [
        'linkage_groups.id',
        'population_loci.id'
      ]
    ]
  end

  def self.ref_columns
    [
      'linkage_group_id',
      'population_locus_id'
    ]
  end

  include Annotable
end
