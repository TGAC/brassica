class PlantPopulation < ActiveRecord::Base

  belongs_to :population_type_lookup, foreign_key: 'population_type'

  belongs_to :male_parent_line, class_name: 'PlantLine',
             foreign_key: 'male_parent_line'

  belongs_to :female_parent_line, class_name: 'PlantLine',
             foreign_key: 'female_parent_line'

  has_many :plant_population_lists, foreign_key: 'plant_population_id'

  has_many :linkage_maps, foreign_key: 'mapping_population'

  has_many :population_loci, foreign_key: 'plant_population'

  has_many :processed_trait_datasets, foreign_key: 'population_id'

  has_and_belongs_to_many :plant_lines,
                          join_table: 'plant_population_lists',
                          foreign_key: 'plant_population_id',
                          association_foreign_key: 'plant_line_name'

  include Filterable

  scope :by_name, -> { order(:plant_population_id) }

  def self.grouped(params = nil)
    count = 'count(plant_lines.plant_line_name)'
    query = (params && params[:query].present?) ? filter(params) : all
    query.
      select(table_columns + [count]).
      includes(:plant_lines).
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
      :species,
      :canonical_population_name,
      :female_parent_line,
      :male_parent_line,
      :population_type
    ]
  end
end
