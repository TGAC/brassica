class MarkerAssay < ActiveRecord::Base
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
             counter_cache: 'marker_assays_a_count'
  belongs_to :primer_b,
             class_name: 'Primer',
             foreign_key: 'primer_b_id',
             counter_cache: 'marker_assays_b_count'

  belongs_to :probe, counter_cache: true
  belongs_to :user

  has_many :population_loci
  has_many :map_positions

  validates :marker_assay_name,
            presence: true,
            uniqueness: true

  validates :canonical_marker_name,
            presence: true

  after_update { population_loci.each(&:touch) }

  include Searchable
  include Relatable
  include Filterable
  include Publishable

  def self.table_data(params = nil)
    uid = User.current_user_id
    ma = MarkerAssay.arel_table
    pra = Primer.arel_table
    pr = Probe.arel_table

    primer_subquery = Primer.visible
    probe_subquery = Probe.visible

    query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
    query = query.
      joins {[
        primer_subquery.as('primer_as').on { primer_a_id == primer_as.id }.outer,
        primer_subquery.as('primer_bs').on { primer_b_id == primer_bs.id }.outer,
        probe_subquery.as('prb').on { probe_id == prb.id }.outer
      ]}

    # query = query.
    #   joins{primer_a.outer}.where(pra[:user_id].eq(uid).or(pra[:published].eq(true)).or(ma[:primer_a_id].eq(nil))).
    #   joins{primer_b.outer}.where(prb[:user_id].eq(uid).or(prb[:published].eq(true)).or(ma[:primer_b_id].eq(nil))).
    #   joins{probe.outer}.where(pr[:user_id].eq(uid).or(pr[:published].eq(true)).or(ma[:probe_id].eq(nil))).
    query = query.
      where(ma[:user_id].eq(uid).or(ma[:published].eq(true)))
    query.pluck(*(table_columns + count_columns + ref_columns))
  end

  def self.table_columns
    [
      'marker_assay_name',
      'canonical_marker_name',
      'marker_type',
      'primer_as.primer AS primer_a',
      'primer_bs.primer AS primer_b',
      'separation_system',
      'prb.probe_name AS probe_name'
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
