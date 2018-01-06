class TraitDescriptor < ActiveRecord::Base
  belongs_to :user
  belongs_to :trait
  belongs_to :plant_part

  after_update { processed_trait_datasets.each(&:touch) }
  before_destroy { processed_trait_datasets.each(&:touch) }

  has_many :trait_grades
  has_many :trait_scores
  has_many :processed_trait_datasets

  validates :trait_id, :units_of_measurements, :scoring_method, presence: true

  include Relatable
  include Filterable
  include Searchable
  include AttributeValues
  include Publishable

  delegate :name, to: :trait, prefix: true

  def self.table_data(params = nil, uid = nil)
    pt_subquery = TraitScore.visible(uid).
      select('trait_descriptor_id, ARRAY_AGG(DISTINCT(plant_trial_id)) as plant_trial_ids').
      joins(:plant_scoring_unit).
      group('trait_descriptor_id').
      merge(PlantScoringUnit.visible(uid))

    t_subquery = Trait.all
    pp_subquery = PlantPart.all

    query = all.
      joins("LEFT OUTER JOIN #{pt_subquery.as('plant_trials_subquery').to_sql} ON trait_descriptors.id = plant_trials_subquery.trait_descriptor_id").
      joins("LEFT OUTER JOIN #{t_subquery.as('traits').to_sql} ON trait_descriptors.trait_id = traits.id").
      joins("LEFT OUTER JOIN #{pp_subquery.as('plant_parts').to_sql} ON trait_descriptors.plant_part_id = plant_parts.id")

    query = (params && (params[:query] || params[:fetch])) ? filter(params, query) : query
    query = query.where(arel_table[:user_id].eq(uid).or(arel_table[:published].eq(true)))
    query = join_counters(query, uid)
    query.pluck(*(table_columns + privacy_adjusted_count_columns + ref_columns))
  end

  def self.table_columns
    [
      'descriptor_label',
      'traits.name',
      'units_of_measurements',
      'scoring_method',
      'materials',
      'plant_parts.plant_part'
    ]
  end

  def self.count_columns
    [
      'trait_scores_count'
    ]
  end

  def self.permitted_params
    [
      :fetch,
      search: [
        'traits.name'
      ],
      query: params_for_filter(table_columns) +
        [
          'user_id',
          'id',
          'id' => []
        ]
    ]
  end

  def self.ref_columns
    [
      'traits.label',
      'plant_parts.label',
      'plant_trial_ids'
    ]
  end

  def self.json_options
    {
      except: :descriptor_name,
      include: [:trait_grades, :trait]
    }
  end

  def as_json(options = {})
    super(options.merge(methods: [:trait_name] + (options[:methods] || [])))
  end

  include Annotable
end
