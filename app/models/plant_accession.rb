class PlantAccession < ActiveRecord::Base

  belongs_to :plant_line

  has_many :plant_scoring_units

  validates :plant_accession,
            presence: true,
            uniqueness: true

  validates :year_produced,
            presence: true,
            length: { is: 4 }

  include Relatable
  include Filterable
  include Pluckable

  def self.table_data(params = nil)
    query = (params && params[:query].present?) ? filter(params) : all
    query.pluck_columns
  end

  def self.table_columns
    [
      'plant_accession',
      'plant_lines.plant_line_name',
      'plant_accession_derivation',
      'accession_originator',
      'originating_organisation',
      'year_produced',
      'date_harvested'
      # TODO FIXME these two have to wait for #204 fix
      # 'female_parent_plant_id"
      # 'male_parent_plant_id"
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
      'plant_line_id'
    ]
  end

  include Annotable
end
