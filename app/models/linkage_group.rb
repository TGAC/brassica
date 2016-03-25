class LinkageGroup < ActiveRecord::Base
  belongs_to :linkage_map, counter_cache: true
  belongs_to :user

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
  after_update { qtls.each(&:touch) }

  include Relatable
  include Filterable
  include Pluckable
  include Searchable
  include Publishable

  def self.table_data(params = nil)
    query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
    query.pluck_columns
  end

  def self.table_columns
    [
      'linkage_group_label',
      'linkage_group_name',
      'linkage_maps.linkage_map_label',
      'total_length',
      'lod_threshold',
      'consensus_group_assignment',
      'consensus_group_orientation'
    ]
  end

  def self.count_columns
    [
      'map_positions_count',
      'map_locus_hits_count',
      'qtls_count'
    ]
  end

  def self.ref_columns
    [
      'linkage_map_id'
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
