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

  has_many :population_loci

  validates :marker_assay_name,
            presence: true,
            uniqueness: true

  validates :canonical_marker_name,
            presence: true

  after_update { population_loci.each(&:touch) }

  include Searchable
  include Relatable
  include Filterable

  def self.table_data(params = nil)
    query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
    query.
      includes(:primer_a, :primer_b, :probe).
      pluck(*(table_columns + count_columns + ref_columns))
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
      'population_loci_count'
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
      query: [
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
