class LinkageMap < ActiveRecord::Base

  belongs_to :plant_population, counter_cache: true, touch: true
  belongs_to :user

  has_many :linkage_groups
  has_many :genotype_matrices
  has_many :map_locus_hits
  has_many :qtl_jobs

  validates :linkage_map_label,
            presence: true,
            uniqueness: true

  validates :linkage_map_name,
            presence: true

  validates :map_version_no,
            presence: true,
            length: { minimum: 1, maximum: 3 }

  after_update { map_locus_hits.each(&:touch) }

  default_scope { includes(plant_population: :taxonomy_term) }

  include Relatable
  include Filterable
  include Pluckable
  include Searchable

  def self.table_data(params = nil)
    query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
    query.pluck_columns
  end

  def self.table_columns
    [
      'taxonomy_terms.name',
      'plant_populations.name',
      'linkage_map_label',
      'linkage_map_name',
      'map_version_no',
      'map_version_date'
    ]
  end

  def self.count_columns
    [
      'linkage_groups_count',
      'map_locus_hits_count'
    ]
  end

  def self.ref_columns
    [
      'plant_population_id',
      'pubmed_id'
    ]
  end

  def self.permitted_params
    [
      :fetch,
      query: params_for_filter(table_columns) +
        [
          'plant_populations.id',
          'linkage_groups.id',
          'id'
        ]
    ]
  end

  def self.indexed_json_structure
    {
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
    }
  end

  def published?
    updated_at < Time.now - 1.week
  end

  include Annotable
end
