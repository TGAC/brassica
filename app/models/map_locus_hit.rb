class MapLocusHit < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name ['brassica', Rails.env, base_class.name.underscore.pluralize].join("_")

  belongs_to :linkage_map, counter_cache: true
  belongs_to :linkage_group, counter_cache: true
  belongs_to :map_position, counter_cache: true
  belongs_to :population_locus, counter_cache: true

  validates :consensus_group_assignment,
            presence: true

  validates :canonical_marker_name,
            presence: true

  validates :associated_sequence_id,
            presence: true

  validates :sequence_source_acronym,
            presence: true

  after_touch { __elasticsearch__.index_document }

  include Filterable
  include Pluckable

  def self.table_data(params = nil)
    query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
    query.pluck_columns
  end

  def self.table_columns
    [
      'consensus_group_assignment',
      'canonical_marker_name',
      'map_positions.map_position',
      'population_loci.mapping_locus',
      'linkage_maps.linkage_map_label',
      'linkage_groups.linkage_group_label',
      'associated_sequence_id',
      'sequence_source_acronym',
      'atg_hit_seq_id',
      'atg_hit_seq_source',
      'bac_hit_seq_id',
      'bac_hit_seq_source',
      'bac_hit_name'
    ]
  end

  def self.permitted_params
    [
      :fetch,
      query: [
        'population_loci.id',
        'linkage_maps.id',
        'linkage_groups.id',
        'map_positions.id'
      ]
    ]
  end

  def self.ref_columns
    [
      'map_position_id',
      'linkage_map_id',
      'linkage_group_id',
      'population_locus_id'
    ]
  end

  def as_indexed_json(options = {})
    as_json(
      only: [
        :consensus_group_assignment,
        :canonical_marker_name,
        :associated_sequence_id,
        :sequence_source_acronym,
        :atg_hit_seq_id,
        :atg_hit_seq_source,
        :bac_hit_seq_id,
        :bac_hit_seq_source,
        :bac_hit_name
      ],
      include: {
        map_position: { only: [:map_position] },
        population_locus: { only: [:mapping_locus] },
        linkage_map: { only: [:linkage_map_label] },
        linkage_group: { only: [:linkage_group_label] }
      }
    )
  end
end
