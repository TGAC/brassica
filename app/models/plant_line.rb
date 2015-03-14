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

  def self.grid_data(filter)
    columns =
      'plant_line_name',
      'taxonomy_terms.name',
      'common_name',
      'previous_line_name',
      'date_entered',
      'data_owned_by',
      'organisation'

    query = where(plant_line_name: filter[:plant_line_names]) if filter[:plant_line_names].present?
    query = where('plant_line_name ILIKE ?', "%#{filter[:search]}%") if filter[:search].present?
    query ||= none

    query
      .joins(:taxonomy_term)
      .order(:plant_line_name)
      .pluck(*columns)
  end
end
