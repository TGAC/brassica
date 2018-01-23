class PlantVariety < ApplicationRecord
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

  validates :plant_variety_name,
            presence: true,
            uniqueness: true

  include Filterable
  include Pluckable
  include Searchable
  include Publishable
  include TableData

  default_scope { order('plant_variety_name') }

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
      include: [:countries_of_origin, :countries_registered]
    }
  end

  include Annotable
end
