class PlantVariety < ActiveRecord::Base
  belongs_to :user

  has_and_belongs_to_many :countries_of_origin,
                          class_name: 'Country',
                          join_table: 'plant_variety_country_of_origin'

  has_and_belongs_to_many :countries_registered,
                          class_name: 'Country',
                          join_table: 'plant_variety_country_registered'

  after_update { plant_lines.each(&:touch) }
  before_destroy { plant_lines.each(&:touch) }

  has_many :plant_lines
  has_many :plant_accessions
  has_many :plant_variety_accessions

  validates :plant_variety_name,
            presence: true,
            uniqueness: true

  include Filterable
  include Searchable
  include Relatable
  include Publishable
  include TableData

  default_scope { order('plant_variety_name') }

  def self.table_data(params = nil, uid = nil)
    pva_counts_subquery = PlantVarietyAccession.
      visible(uid).
      group(:plant_variety_id).
      select("count(*) AS plant_variety_accessions_count, plant_variety_id")

    query = all.
      joins {[
        pva_counts_subquery.as('plant_variety_accession_counts').
          on { plant_varieties.id == plant_variety_accession_counts.plant_variety_id }.outer
      ]}

    query = (params && (params[:query] || params[:fetch])) ? filter(params, query) : query
    query = query.where(arel_table[:user_id].eq(uid).or(arel_table[:published].eq(true)))

    query = join_counters(query, uid, except: ['plant_accessions_count'])
    query.pluck(*(
      table_columns +
      privacy_adjusted_count_columns(except: ['plant_accessions_count']) +
      ['COALESCE(plant_variety_accessions_count, 0) AS plant_accessions_count'] +
      ref_columns
    ))
  end

  def self.table_columns
    [
      'plant_variety_name',
      'crop_type',
      'data_attribution',
      'year_registered',
      'breeders_variety_code',
      'owner',
      'quoted_parentage',
      'female_parent',
      'male_parent'
    ]
  end

  def self.count_columns
    [
      'plant_accessions_count'
    ]
  end

  def self.permitted_params
    [
      :fetch,
      query: params_for_filter(table_columns) +
        [
          'plant_populations.id',
          'user_id',
          'id',
          'id' => []
        ],
      search: [
        :plant_variety_name
      ]
    ]
  end

  def self.json_options
    {
      include: [:countries_of_origin, :countries_registered],
      except: [:plant_variety_accessions]
    }
  end

  def plant_accessions_count
    plant_variety_accessions.count
  end

  include Annotable
end
