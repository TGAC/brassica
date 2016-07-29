class PlantTrial < ActiveRecord::Base
  belongs_to :plant_population, counter_cache: true, touch: true
  belongs_to :country
  belongs_to :user

  after_update { plant_scoring_units.each(&:touch) }

  has_many :plant_scoring_units, dependent: :destroy
  has_many :processed_trait_datasets

  has_attached_file :layout

  validates :plant_trial_name, presence: true, uniqueness: true
  validates :project_descriptor, :trial_year, :place_name, presence: true
  validates :latitude, allow_blank: true, numericality: {
    greater_than_or_equal_to: -90,
    less_than_or_equal_to: 90
  }
  validates :longitude, allow_blank: true, numericality: {
    greater_than_or_equal_to: -180,
    less_than_or_equal_to: 180
  }

  validates_attachment_content_type :layout, content_type: %w(image/png image/gif image/jpeg)

  include Relatable
  include Filterable
  include Pluckable
  include Searchable
  include AttributeValues
  include Publishable
  include TableData

  # NOTE: this one works per-trial and provides data for so-called 'pivot' trial scoring table
  def scoring_table_data(uid = nil)
    ts = TraitScore.arel_table

    psu_subquery = PlantScoringUnit.visible(uid)
    td_subquery = TraitDescriptor.visible(uid)

    all_scores = TraitScore.
      joins {[
        psu_subquery.as('plant_scoring_units').on { plant_scoring_unit_id == plant_scoring_units.id }.outer,
        td_subquery.as('trait_descriptors').on { trait_descriptor_id == trait_descriptors.id }.outer
      ]}
    all_scores = all_scores.
      where(plant_scoring_units: { plant_trial_id: self.id }).
      where(ts[:user_id].eq(uid).or(ts[:published].eq(true))).
      order('plant_scoring_units.scoring_unit_name asc, trait_descriptors.id asc').
      group_by(&:plant_scoring_unit_id)

    plant_scoring_units.visible(uid).order('scoring_unit_name asc').map do |unit|
      scores = all_scores[unit.id] || []

      [unit.scoring_unit_name] +
        trait_descriptors.pluck(:id).map do |td_id|
          scores_for_trait = scores.select{ |s| s.trait_descriptor_id == td_id.to_i}
          (1..replicate_numbers[td_id.to_i]).map do |replicate_number|
            replicate = scores_for_trait.detect{ |s| s.technical_replicate_number == replicate_number }
            replicate ? replicate.score_value : '-'
          end
        end.flatten +
        [unit.id]
    end
  end

  def trait_descriptors
    TraitDescriptor.
      joins(trait_scores: :plant_scoring_unit).
      where(plant_scoring_units: { plant_trial_id: id }).
      order('trait_descriptors.id asc').uniq
  end

  # Gives technical replicate numbers for each trait descriptor
  def replicate_numbers
    TraitScore.
      joins(:plant_scoring_unit).
      where(plant_scoring_units: { plant_trial_id: id }).
      group(:trait_descriptor_id).
      maximum(:technical_replicate_number)
  end

  def self.table_columns
    [
      'plant_trial_name',
      'plant_trial_description',
      'project_descriptor',
      'plant_populations.name',
      'trial_year',
      'trial_location_site_name',
      'countries.country_name',
      'institute_id',
      'layout_file_name',
      'id'
    ]
  end

  def self.numeric_columns
    [
      'trial_year'
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
      search: [
        'project_descriptor',
      ],
      query: params_for_filter(table_columns) +
        [
          'project_descriptor',
          'plant_populations.id',
          'user_id',
          'id' => []
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

  include Annotable
end
