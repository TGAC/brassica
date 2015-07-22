class PlantVariety < ActiveRecord::Base

  belongs_to :user

  has_and_belongs_to_many :countries_of_origin,
                          class_name: 'Country',
                          join_table: 'plant_variety_country_of_origin'

  has_and_belongs_to_many :countries_registered,
                          class_name: 'Country',
                          join_table: 'plant_variety_country_registered'

  has_many :plant_lines

  validates :plant_variety_name,
            presence: true,
            uniqueness: true

  include Filterable
  include Pluckable
  include Searchable

  scope :by_name, -> { order(:plant_variety_name) }

  def self.table_data(params = nil)
    query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
    query.by_name.pluck_columns
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

  def self.permitted_params
    [
      :fetch,
      query: params_for_filter(table_columns) + ['id'],
      search: [
        :plant_variety_name
      ]
    ]
  end

  def self.json_options
    {
      include: [:countries_of_origin, :countries_registered]
    }
  end

  def published?
    updated_at < Time.now - 1.week
  end

  include Annotable
end
