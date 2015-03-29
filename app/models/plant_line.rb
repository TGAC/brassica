class PlantLine < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

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

  after_update { mothered_descendants.each(&:touch) }
  after_update { fathered_descendants.each(&:touch) }

  after_touch { __elasticsearch__.index_document }

  def self.filter(params, columns: nil)
    columns ||= [
      'plant_line_name',
      'taxonomy_terms.name',
      'common_name',
      'previous_line_name',
      'date_entered',
      'data_owned_by',
      'organisation'
    ]

    params = filter_params(params)
    query = where(params[:query]) if params[:query].present?
    query = where('plant_line_name ILIKE ?', "%#{params[:search]}%") if params[:search].present?
    query ||= none

    columns.each do |column|
      relation = column.to_s.split('.')[0].pluralize if column.to_s.include? '.'
      next unless relation
      relation = relation.singularize unless reflections.keys.include?(relation)
      query = query.joins(relation.to_sym)
    end

    params[:query].each do |k,_|
      query = query.joins(k.to_s.split('.')[0].to_sym) if k.to_s.include? '.'
    end if params[:query].present?

    query.order(:plant_line_name).pluck(*columns)
  end

  def self.genetic_statuses
    order('genetic_status').pluck('DISTINCT genetic_status').reject(&:blank?)
  end

  def as_indexed_json(options = {})
    as_json(
      only: [
        :id, :plant_line_name, :common_name, :genetic_status,
        :previous_line_name
      ],
      include: {
        taxonomy_term: { only: [:name] }
      }
    )
  end

  private

  def self.filter_params(unsafe_params)
    unsafe_params = ActionController::Parameters.new(unsafe_params)
    unsafe_params.permit(
      :search,
      query: [
        'plant_populations.plant_population_id',
        plant_line_name: []
      ]
    )
  end
end
