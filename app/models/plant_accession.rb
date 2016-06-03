class PlantAccession < ActiveRecord::Base
  belongs_to :plant_line
  belongs_to :plant_variety
  belongs_to :user

  after_update { plant_scoring_units.each(&:touch) }
  before_destroy { plant_scoring_units.each(&:touch) }

  has_many :plant_scoring_units

  validates :plant_accession,
            presence: true,
            uniqueness: true

  validates :year_produced,
            length: { is: 4 },
            allow_blank: true

  validate :plant_line_xor_plant_variety

  include Relatable
  include Filterable
  include Pluckable
  include Publishable
  include TableData

  def plant_line_xor_plant_variety
    if plant_line_id.present?
      if plant_variety.present?
        errors.add(:plant_line, 'A plant accession may not be simultaneously linked to a plant line and a plant variety.')
        errors.add(:plant_variety, 'A plant accession may not be simultaneously linked to a plant line and a plant variety.')
      end
    else
      if plant_variety.blank?
        errors.add(:plant_line, 'A plant accession must be linked to either a plant line or a plant variety.')
        errors.add(:plant_variety, 'A plant accession must be linked to either a plant line or a plant variety.')
      end
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

  def self.count_columns
    [
      'plant_scoring_units_count'
    ]
  end

  def self.permitted_params
    [
      query: params_for_filter(table_columns) +
        [
          'id'
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
