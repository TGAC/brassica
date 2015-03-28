class PlantLine < ActiveRecord::Base
  self.primary_key = 'plant_line_name'

  belongs_to :plant_variety, foreign_key: 'plant_variety_name'

  belongs_to :taxonomy_term

  has_many :plant_population_lists, foreign_key: 'plant_line_name'

  has_many :fathered_descendants, class_name: 'PlantPopulation',
           foreign_key: 'male_parent_line'

  has_many :mothered_descendants, class_name: 'PlantPopulation',
           foreign_key: 'female_parent_line'

  has_many :plant_accessions, foreign_key: 'plant_line_name'

  has_and_belongs_to_many :plant_populations,
                          join_table: 'plant_population_lists',
                          foreign_key: 'plant_line_name',
                          association_foreign_key: 'plant_population_id'

  include Filterable
  include Pluckable

  scope :by_name, -> { order(:plant_line_name) }

  def self.table_data(params)
    query = filter(params)
    query.by_name.pluck_columns(table_columns)
  end

  def self.genetic_statuses
    order('genetic_status').pluck('DISTINCT genetic_status').reject(&:blank?)
  end

  private

  def self.permitted_params
    [
      search: [
        :plant_line_name,
        'plant_lines.plant_line_name'
      ],
      query: [
        'plant_populations.plant_population_id',
        plant_line_name: [],
        'plant_lines.plant_line_name' => []
      ]
    ]
  end

  def self.table_columns
    [
      'plant_line_name',
      'taxonomy_terms.name',
      'common_name',
      'previous_line_name',
      'date_entered',
      'data_owned_by',
      'organisation'
    ]
  end
end
