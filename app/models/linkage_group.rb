class LinkageGroup < ActiveRecord::Base

  has_many :linkage_maps, through: :map_linkage_group_lists
  has_many :map_linkage_group_lists
  has_many :map_positions
  has_many :map_locus_hits
  has_many :qtls

  validates :linkage_group_label,
            presence: true,
            uniqueness: true

  validates :linkage_group_name,
            presence: true

  validates :consensus_group_assignment,
            presence: true

  after_update { map_positions.each(&:touch) }
  after_update { map_locus_hits.each(&:touch) }

  include Relatable
  include Filterable
  include Pluckable
  include Searchable

  def self.table_data(params = nil)
    query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
    query.pluck_columns
  end

  def self.table_columns
    [
      'linkage_group_label',
      'linkage_group_name',
      'total_length',
      'lod_threshold',
      'consensus_group_assignment',
      'consensus_group_orientation'
    ]
  end

  def self.count_columns
    [
      'linkage_groups.map_linkage_group_lists_count AS linkage_maps_count',
      'map_positions_count',
      'map_locus_hits_count'
    ]
  end

  def self.permitted_params
    [
      :fetch,
      query: params_for_filter(table_columns) +
        [
          'linkage_maps.id',
          'id'
        ]
    ]
  end

  include Annotable
end
