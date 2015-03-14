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

    safe_query = grid_data_params(filter[:query])
    query = where(safe_query) if safe_query.present?
    query = where('plant_line_name ILIKE ?', "%#{filter[:search]}%") if filter[:search].present?
    query ||= none

    safe_query.each do |k,_|
      query = query.joins(k.to_s.split('.')[0].to_sym) if k.to_s.include? '.'
    end if safe_query.present?

    query
      .joins(:taxonomy_term)
      .order(:plant_line_name)
      .pluck(*columns)
  end


  private

  def self.grid_data_params(raw_query)
    parameters = ActionController::Parameters.new(raw_query)
    parameters.permit('plant_populations.plant_population_id',
                      plant_line_name: []
    )
  end
end
