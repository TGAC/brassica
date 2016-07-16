class LinkageGroup < ActiveRecord::Base
  belongs_to :linkage_map, counter_cache: true, touch: true
  belongs_to :user

  after_update { map_positions.each(&:touch) }
  after_update { map_locus_hits.each(&:touch) }
  after_update { qtls.each(&:touch) }
  before_destroy { map_positions.each(&:touch) }
  before_destroy { map_locus_hits.each(&:touch) }
  before_destroy { qtls.each(&:touch) }

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

  include Relatable
  include Filterable
  include Pluckable
  include Searchable
  include Publishable
  include TableData

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
          'user_id',
          'id'
        ]
    ]
  end

  include Annotable
end
