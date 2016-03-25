class PlantLine < ActiveRecord::Base
  belongs_to :plant_variety
  belongs_to :taxonomy_term
  belongs_to :user

  has_many :fathered_descendants, class_name: 'PlantPopulation',
           foreign_key: 'male_parent_line_id',
           dependent: :nullify
  has_many :mothered_descendants, class_name: 'PlantPopulation',
           foreign_key: 'female_parent_line_id',
           dependent: :nullify
  has_many :plant_accessions,
           dependent: :nullify

  has_many :plant_population_lists, dependent: :delete_all
  has_many :plant_populations,
           through: :plant_population_lists

  after_update { mothered_descendants.each(&:touch) }
  after_update { fathered_descendants.each(&:touch) }

  include Filterable
  include Pluckable
  include Searchable
  include Publishable

  validates :plant_line_name,
            presence: true,
            uniqueness: true
  validates :user,
            presence: { on: :create }

  scope :by_name, -> { order(:plant_line_name) }
  scope :where_id_or_name, ->(id_or_name) {
    where("id=:id OR plant_line_name ILIKE :name", id: id_or_name.to_i, name: id_or_name.to_s)
  }

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
      'sequence_identifier',
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
      query: params_for_filter(table_columns) +
        [
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
