class PlantPopulation < ActiveRecord::Base
  belongs_to :taxonomy_term
  belongs_to :population_type
  belongs_to :male_parent_line, class_name: 'PlantLine',
             foreign_key: 'male_parent_line_id'
  belongs_to :female_parent_line, class_name: 'PlantLine',
             foreign_key: 'female_parent_line_id'
  belongs_to :user

  has_many :linkage_maps,
           dependent: :nullify
  has_many :population_loci,
           dependent: :nullify
  has_many :plant_trials,
           dependent: :nullify

  has_many :plant_population_lists, dependent: :delete_all
  has_many :plant_lines,
           through: :plant_population_lists

  validates :name,
            presence: true,
            uniqueness: true
  validates :user,
            presence: { on: :create }

  after_update { population_loci.each(&:touch) }
  after_update { linkage_maps.each(&:touch) }
  after_update { plant_trials.each(&:touch) }

  include Relatable
  include Filterable
  include Searchable
  include Publishable

  scope :by_name, -> { order('plant_populations.name') }
  scope :visible, -> { where(PlantPopulation.arel_table[:user_id].eq(User.current_user_id).
                                 or(PlantPopulation.arel_table[:published].eq(true))) }

  def self.table_data(params = nil)
    uid = User.current_user_id
    pp = PlantPopulation.arel_table
    fpl = PlantLine.arel_table

    subquery = PlantLine.visible

    query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
    query = query.
      joins {[
        subquery.as('fpls').on { female_parent_line_id == fpls.id }.outer,
        subquery.as('mpls').on { male_parent_line_id == mpls.id }.outer,
        taxonomy_term.outer,
        population_type.outer
      ]}
    query = query.
      where(pp[:user_id].eq(uid).or(pp[:published].eq(true)))
    query = query.by_name
    query.pluck(*(table_columns + count_columns + ref_columns))
  end

  def self.table_columns
    [
      'taxonomy_terms.name',
      'plant_populations.name',
      'canonical_population_name',
      'fpls.plant_line_name AS female_parent_line',
      'mpls.plant_line_name AS male_parent_line',
      'pop_type_lookup.population_type',
      'description'
    ]
  end

  def self.count_columns
    [
      'plant_population_lists_count AS plant_lines_count',
      'linkage_maps_count',
      'plant_trials_count',
      'population_loci_count'
    ]
  end

  def self.indexed_json_structure
    {
      only: [
        :name, :canonical_population_name, :description
      ],
      include: {
        taxonomy_term: { only: :name },
        population_type: { only: :population_type },
        female_parent_line: { only: :plant_line_name },
        male_parent_line: { only: :plant_line_name },
      }
    }
  end

  def self.permitted_params
    [
      :fetch,
      search: [
        'name',
        'canonical_population_name',
        'description'
      ],
      query: [
        'id',
        'name',
        'canonical_population_name',
        'description'
      ]
    ]
  end

  def self.ref_columns
    [
      'female_parent_line_id',
      'male_parent_line_id'
    ]
  end

  include Annotable
end
