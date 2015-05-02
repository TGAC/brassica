class LinkageGroup < ActiveRecord::Base

  has_many :linkage_maps, through: :map_linkage_group_lists

  has_many :map_linkage_group_lists

  has_many :map_positions

  has_many :map_locus_hits

  has_many :qtls

  validates :linkage_group_label,
            presence: true

  validates :linkage_group_name,
            presence: true

  validates :consensus_group_assignment,
            presence: true

  include Relatable
  include Filterable
  include Pluckable

  def self.table_data(params = nil)
    query = (params && params[:query].present?) ? filter(params) : all
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
      'linkage_groups.map_linkage_group_lists_count AS linkage_maps_count'
    ]
  end

  def self.permitted_params
    [
      query: [
        'linkage_maps.id'
      ]
    ]
  end

  include Annotable
end
