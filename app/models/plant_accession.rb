class PlantAccession < ActiveRecord::Base
  belongs_to :plant_line, counter_cache: true
  belongs_to :plant_variety
  belongs_to :user

  after_update { plant_scoring_units.each(&:touch) }
  before_destroy { plant_scoring_units.each(&:touch) }

  has_many :plant_scoring_units

  validates :plant_accession,
            presence: true,
            uniqueness: { scope: [:originating_organisation, :year_produced] }

  validates :originating_organisation,
            presence: true

  validates :year_produced,
            length: { is: 4 },
            allow_blank: true

  validate :check_plant_line_xor_plant_variety
  validates :plant_line_id, presence: true, if: 'plant_variety_id.nil?'
  validates :plant_variety_id, presence: true, if: 'plant_line_id.nil?'

  include Relatable
  include Filterable
  include Searchable
  include Publishable

  def self.table_data(params = nil, uid = nil)
    pv_subquery = PlantVariety.visible(uid)
    pl_subquery = PlantLine.visible(uid)

    query = all.
      joins {[
        pl_subquery.as('plant_lines').on { plant_lines.id == plant_accessions.plant_line_id }.outer,
        pv_subquery.as('plant_varieties').on { plant_varieties.id == plant_accessions.plant_variety_id }.outer,
        pv_subquery.as('plant_line_varieties').on { plant_line_varieties.id == plant_lines.plant_variety_id }.outer
    ]}
    query = (params && (params[:query] || params[:fetch])) ? filter(params, query) : query
    query = query.where(arel_table[:user_id].eq(uid).or(arel_table[:published].eq(true)))

    query = join_counters(query, uid)
    query.pluck(*(table_columns + privacy_adjusted_count_columns + ref_columns))
  end

  def self.table_columns
    [
      'plant_accession',
      'plant_lines.plant_line_name',
      'CASE WHEN plant_varieties.id IS NULL THEN plant_line_varieties.plant_variety_name ELSE plant_varieties.plant_variety_name END AS plant_variety_name',
      'plant_accession_derivation',
      'originating_organisation',
      'year_produced',
      'date_harvested'
    ]
  end

  def self.numeric_columns
    [
      'year_produced'
    ]
  end

  def self.count_columns
    [
      'plant_scoring_units_count'
    ]
  end

  def self.permitted_params
    [
      :fetch,
      query: params_for_filter(table_columns) +
        [
          'plant_lines.id',
          'user_id',
          'id',
          'id' => []
        ]
    ]
  end

  def self.ref_columns
    [
      'plant_line_id',
      'COALESCE (plant_varieties.id, plant_line_varieties.id)'
    ]
  end

  def self.indexed_json_structure
    {
      only: [
        :plant_accession,
        :plant_accession_derivation,
        :originating_organisation,
        :year_produced,
        :date_harvested
      ],
      include: {
        plant_line: {
          only: :plant_line_name,
          include: {
            plant_variety: { only: :plant_variety_name }
          }
        },
        plant_variety: { only: :plant_variety_name }
      }
    }
  end

  include Annotable

  private

  def check_plant_line_xor_plant_variety
    if plant_line_id.present? && plant_variety_id.present?
      errors.add(:plant_line_id, :not_with_plant_variety)
      errors.add(:plant_variety_id, :not_with_plant_line)
    end
  end
end
