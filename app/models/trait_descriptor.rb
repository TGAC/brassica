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
  include Pluckable
  include Searchable
  include AttributeValues
  include Publishable
  include TableData

  delegate :name, to: :trait, prefix: true

  def self.table_columns
    [
      'descriptor_label',
      'traits.name',
      'units_of_measurements',
      'scoring_method',
      'materials',
      'plant_parts.plant_part',
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
          'id'
        ]
    ]
  end

  def self.ref_columns
    [
      'traits.label',
      'plant_parts.label'
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
