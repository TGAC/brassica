class MarkerAssay < ApplicationRecord
  belongs_to :marker_sequence_assignment

  belongs_to :restriction_enzyme_a,
             class_name: 'RestrictionEnzyme',
             foreign_key: 'restriction_enzyme_a_id'
  belongs_to :restriction_enzyme_b,
             class_name: 'RestrictionEnzyme',
             foreign_key: 'restriction_enzyme_b_id'

  belongs_to :primer_a,
             class_name: 'Primer',
             foreign_key: 'primer_a_id',
             counter_cache: 'marker_assays_a_count',
             touch: true
  belongs_to :primer_b,
             class_name: 'Primer',
             foreign_key: 'primer_b_id',
             counter_cache: 'marker_assays_b_count',
             touch: true

  belongs_to :probe, counter_cache: true, touch: true
  belongs_to :user

  after_update { population_loci.each(&:touch) }
  after_update { map_positions.each(&:touch) }
  before_destroy { population_loci.each(&:touch) }
  before_destroy { map_positions.each(&:touch) }

  has_many :population_loci
  has_many :map_positions

  validates :marker_assay_name,
            presence: true,
            uniqueness: true

  validates :canonical_marker_name,
            presence: true

  include Searchable
  include Relatable
  include Filterable
  include Publishable

  def self.table_data(params = nil, uid = nil)
    primer_subquery = Primer.visible(uid)
    probe_subquery = Probe.visible(uid)

    query = MarkerAssay.
      joins("LEFT OUTER JOIN #{primer_subquery.as('primers').to_sql} ON primers.id = marker_assays.primer_a_id").
      joins("LEFT OUTER JOIN #{primer_subquery.as('primer_bs_marker_assays').to_sql} ON primer_bs_marker_assays.id = marker_assays.primer_b_id").
      joins("LEFT OUTER JOIN #{probe_subquery.as('probes').to_sql} ON probes.id = marker_assays.probe_id")

    query = (params && (params[:query] || params[:fetch])) ? filter(params, query) : query
    query = query.
      where(arel_table[:user_id].eq(uid).or(arel_table[:published].eq(true)))
    query = join_counters(query, uid)
    query.pluck(*(table_columns + privacy_adjusted_count_columns + ref_columns))
  end

  def self.table_columns
    [
      'marker_assay_name',
      'canonical_marker_name',
      'marker_type',
      'primers.primer AS primer_a',
      'primer_bs_marker_assays.primer AS primer_b',
      'separation_system',
      'probes.probe_name'
    ]
  end

  def self.count_columns
    [
      'population_loci_count',
      'map_positions_count'
    ]
  end

  def self.indexed_json_structure
    {
      only: [
        :marker_assay_name,
        :canonical_marker_name,
        :marker_type,
        :separation_system
      ],
      include: {
        probe: { only: :probe_name },
        primer_a: { only: :primer },
        primer_b: { only: :primer },
      }
    }
  end

  def self.permitted_params
    [
      :fetch,
      query: params_for_filter(table_columns) +
        [
          'primer_a_id',
          'primer_b_id',
          'probes.id',
          'user_id',
          'id'
        ]
    ]
  end

  def self.ref_columns
    [
      'primer_a_id',
      'primer_b_id',
      'probe_id'
    ]
  end

  include Annotable
end
