class PlantLine < ActiveRecord::Base
  belongs_to :plant_variety
  belongs_to :taxonomy_term
  belongs_to :user

  before_destroy { mothered_descendants.each(&:touch) }
  before_destroy { fathered_descendants.each(&:touch) }
  before_destroy { plant_accessions.each(&:touch) }
  after_update { mothered_descendants.each(&:touch) }
  after_update { fathered_descendants.each(&:touch) }
  after_update { plant_accessions.each(&:touch) }

  has_many :fathered_descendants, class_name: 'PlantPopulation',
           foreign_key: 'male_parent_line_id'
  has_many :mothered_descendants, class_name: 'PlantPopulation',
           foreign_key: 'female_parent_line_id'
  has_many :plant_accessions

  has_many :plant_population_lists, dependent: :delete_all
  has_many :plant_populations, through: :plant_population_lists

  after_update :cascade_visibility

  include Filterable
  include Pluckable
  include Searchable
  include Publishable
  include TableData

  validates :plant_line_name,
            presence: true,
            uniqueness: true
  validates :user,
            presence: { on: :create }

  default_scope { order('plant_line_name') }

  scope :where_id_or_name, ->(id_or_name) {
    where("id=:id OR plant_line_name ILIKE :name", id: id_or_name.to_i, name: id_or_name.to_s)
  }

  def self.genetic_statuses
    unscope(:order).order('genetic_status').pluck('DISTINCT genetic_status').reject(&:blank?)
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
          'user_id',
          'id',
          'id' => []
        ]
    ]
  end

  def self.ref_columns
    [
      'plant_variety_id'
    ]
  end

  include Annotable

  private

  def cascade_visibility
    if published_changed?
      plant_population_lists.each do |ppl|
        ppl.update_attributes!(published: self.published?, published_on: Time.now)
      end
    end
  end
end
