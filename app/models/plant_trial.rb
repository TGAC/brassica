class PlantTrial < ActiveRecord::Base

  belongs_to :plant_population, counter_cache: true
  belongs_to :country
  belongs_to :user

  has_many :plant_scoring_units, dependent: :destroy
  has_many :processed_trait_datasets

  validates :plant_trial_name, presence: true, uniqueness: true
  validates :project_descriptor, presence: true
  validates :latitude, allow_nil: true, numericality: {
    greater_than_or_equal_to: -90,
    less_than_or_equal_to: 90
  }
  validates :longitude, allow_nil: true, numericality: {
    greater_than_or_equal_to: -180,
    less_than_or_equal_to: 180
  }

  include Relatable
  include Filterable
  include Pluckable
  include Searchable
  include AttributeValues

  def self.table_data(params = nil)
    query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
    query.order(:trial_year).pluck_columns
  end

  def self.table_columns
    [
      'plant_trial_name',
      'plant_trial_description',
      'project_descriptor',
      'plant_populations.name',
      'trial_year',
      'trial_location_site_name',
      'institute_id'
    ]
  end

  def self.count_columns
    [
      'plant_scoring_units_count'
    ]
  end

  def self.permitted_params
    [
      :fetch,
      query: params_for_filter(table_columns) +
        [
          'project_descriptor',
          'plant_populations.id',
          'id'
        ]
    ]
  end

  def self.ref_columns
    [
      'plant_population_id',
      'pubmed_id'
    ]
  end

  def self.json_options
    { include: [:country] }
  end

  def published?
    updated_at < Time.now - 1.week
  end

  include Annotable
end
