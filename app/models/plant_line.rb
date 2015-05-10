class PlantLine < ActiveRecord::Base

  belongs_to :plant_variety
  belongs_to :taxonomy_term

  has_many :plant_population_lists
  has_many :fathered_descendants, class_name: 'PlantPopulation',
           foreign_key: 'male_parent_line_id'
  has_many :mothered_descendants, class_name: 'PlantPopulation',
           foreign_key: 'female_parent_line_id'
  has_many :plant_accessions

  has_and_belongs_to_many :plant_populations,
                          join_table: 'plant_population_lists'

  after_update { mothered_descendants.each(&:touch) }
  after_update { fathered_descendants.each(&:touch) }

  include Filterable
  include Pluckable
  include Searchable

  validates :plant_line_name,
            presence: true

  scope :by_name, -> { order(:plant_line_name) }

  def self.table_data(params = nil)
    query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
    query.by_name.pluck_columns
  end

  def self.genetic_statuses
    order('genetic_status').pluck('DISTINCT genetic_status').reject(&:blank?)
  end

  def self.table_columns
    [
      'taxonomy_terms.name',
      'plant_line_name',
      'common_name',
      'plant_varieties.plant_variety_name',
      'previous_line_name',
      'genetic_status',
      'data_owned_by',
      'organisation'
    ]
  end

  def self.permitted_params
    [
      :fetch,
      search: [
        :plant_line_name,
        'plant_lines.plant_line_name'
      ],
      query: [
        'plant_populations.id',
        'id'
      ]
    ]
  end

  def self.ref_columns
    [
      'plant_variety_id'
    ]
  end

  include Annotable
end
