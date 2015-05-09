class LinkageMap < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name ['brassica', Rails.env, base_class.name.underscore.pluralize].join("_")

  belongs_to :plant_population, counter_cache: true, touch: true

  has_many :linkage_groups, through: :map_linkage_group_lists
  has_many :map_linkage_group_lists
  has_many :genotype_matrices
  has_many :map_locus_hits

  validates :linkage_map_label,
            presence: true

  validates :linkage_map_name,
            presence: true

  validates :map_version_no,
            presence: true,
            length: { minimum: 1, maximum: 3 }

  after_touch { __elasticsearch__.index_document }
  after_update { map_locus_hits.each(&:touch) }

  default_scope { includes(plant_population: :taxonomy_term) }

  include Relatable
  include Filterable
  include Pluckable

  def self.table_data(params = nil)
    query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
    query.pluck_columns
  end

  def self.table_columns
    [
      'taxonomy_terms.name',
      'linkage_map_label',
      'linkage_map_name',
      'plant_populations.name',
      'map_version_no',
      'map_version_date'
    ]
  end

  def self.count_columns
    [
      'linkage_maps.map_linkage_group_lists_count AS linkage_groups_count',
      'map_locus_hits_count'
    ]
  end

  def self.ref_columns
    [
      'pubmed_id'
    ]
  end

  def self.permitted_params
    [
      :fetch,
      query: [
        'plant_populations.id',
        'linkage_groups.id',
        'id'
      ]
    ]
  end

  def as_indexed_json(options = {})
    as_json(
      only: [
        :linkage_map_label,
        :linkage_map_name,
        :map_version_no,
        :map_version_date
      ],
      include: {
        plant_population: {
          only: [:name],
          include: { taxonomy_term: { only: [:name] } }
        }
      }
    )
  end

  include Annotable
end
