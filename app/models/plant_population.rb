class PlantPopulation < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :taxonomy_term

  belongs_to :population_type_lookup, foreign_key: 'population_type'

  belongs_to :male_parent_line, class_name: 'PlantLine',
             foreign_key: 'male_parent_line_id'

  belongs_to :female_parent_line, class_name: 'PlantLine',
             foreign_key: 'female_parent_line_id'

  has_many :plant_population_lists

  has_many :linkage_maps

  has_many :population_loci, class_name: 'PopulationLocus'

  has_many :processed_trait_datasets, foreign_key: 'population_id'

  has_many :plant_trials, foreign_key: 'plant_population'

  has_and_belongs_to_many :plant_lines,
                          join_table: 'plant_population_lists'

  after_touch { __elasticsearch__.index_document }

  include Filterable

  scope :by_name, -> { order(:plant_population_id) }

  def self.grouped(params = nil)
    count = 'count(plant_lines.plant_line_name)'
    query = (params && params[:query].present?) ? filter(params) : all
    query.
      includes(:plant_lines).
      joins(:taxonomy_term).
      group(table_columns).
      by_name.
      pluck(*(table_columns + [count]))
  end

  private

  def self.permitted_params
    [
      query: [
        :plant_population_id
      ]
    ]
  end

  def self.table_columns
    [
      'plant_populations.plant_population_id',
      'taxonomy_terms.name',
      :canonical_population_name,
      :female_parent_line,
      :male_parent_line,
      :population_type
    ]
  end

  def as_indexed_json(options = {})
    plant_line_attrs = [
      :plant_line_name, :common_name, :genetic_status, :previous_line_name
    ]

    as_json(
      only: [
        :id, :plant_population_name, :canonical_population_name, :description,
        :population_type
      ],
      include: {
        taxonomy_term: { only: [:name] },
        female_parent_line: { only: plant_line_attrs },
        male_parent_line: { only: plant_line_attrs },
      }
    )
  end

end
