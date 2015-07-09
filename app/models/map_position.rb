class MapPosition < ActiveRecord::Base

  belongs_to :linkage_group, counter_cache: true
  belongs_to :population_locus, counter_cache: true
  belongs_to :marker_assay, counter_cache: true

  has_many :map_locus_hits

  validates :mapping_locus,
            presence: true

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
      'marker_assays.marker_assay_name',
      'map_position',
      'linkage_groups.linkage_group_label',
      'population_loci.mapping_locus'
    ]
  end

  def self.count_columns
    [
      'map_locus_hits_count'
    ]
  end

  def self.numeric_columns
    [
      'map_position'
    ]
  end

  def self.permitted_params
    [
      :fetch,
      query: [
        'marker_assay_name',
        'marker_assays.id',
        'map_position',
        'linkage_groups.id',
        'population_loci.id',
        'id'
      ]
    ]
  end

  def self.ref_columns
    [
      'marker_assay_id',
      'linkage_group_id',
      'population_locus_id'
    ]
  end

  mapping dynamic: 'false' do
    indexes :map_position
    indexes :marker_assay do
      indexes :marker_assay_name
    end
    indexes :linkage_group do
      indexes :linkage_group_label
    end
    indexes :population_locus do
      indexes :mapping_locus
    end

    MapPosition.numeric_columns.each do |column|
      indexes column, include_in_all: 'false'
    end
  end

  include Annotable
end
