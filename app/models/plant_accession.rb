class PlantAccession < ActiveRecord::Base
  belongs_to :plant_line
  belongs_to :plant_variety
  belongs_to :user

  after_update { plant_scoring_units.each(&:touch) }
  before_destroy { plant_scoring_units.each(&:touch) }

  has_many :plant_scoring_units

  validates :plant_accession,
            presence: true,
            uniqueness: { scope: :originating_organisation }

  validates :originating_organisation,
            presence: true

  validates :year_produced,
            length: { is: 4 },
            allow_blank: true

  validate :plant_line_xor_plant_variety
  validates :plant_line_id, presence: true, if: 'plant_variety_id.nil?'
  validates :plant_variety_id, presence: true, if: 'plant_line_id.nil?'

  include Relatable
  include Filterable
  include Pluckable
  include Searchable
  include Publishable
  include TableData

  def plant_line_xor_plant_variety
    if plant_line_id.present? && plant_variety_id.present?
      errors.add(:plant_line_id, :not_with_plant_variety)
      errors.add(:plant_variety_id, :not_with_plant_line)
    end
  end

  def self.table_columns
    [
      'plant_accession',
      'plant_lines.plant_line_name',
      'plant_varieties.plant_variety_name',
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
          'user_id',
          'id',
          'id' => []
        ]
    ]
  end

  def self.ref_columns
    [
      'plant_line_id',
      'plant_variety_id'
    ]
  end

  include Annotable
end
