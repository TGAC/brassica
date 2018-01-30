# Read-only model based on a database view.
class PlantVarietyAccession < ActiveRecord::Base
  belongs_to :plant_variety
  belongs_to :plant_line

  include Relatable
  include Filterable

  # TODO: not really publishable but it adds required scopes
  include Publishable

  def read_only?
    true
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
          'plant_lines.id',
          'plant_varieties.id',
          'user_id',
          'id',
          'id' => []
        ]
    ]
  end

  include Annotable
end
