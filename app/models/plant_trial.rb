class PlantTrial < ActiveRecord::Base
  belongs_to :plant_population, counter_cache: true, touch: true
  belongs_to :country
  belongs_to :user

  after_update { plant_scoring_units.each(&:touch) }
  around_destroy do |_, block|
    ActiveRecord::Base.delay_touching { block.call }
  end

  has_many :plant_scoring_units, dependent: :destroy
  has_many :processed_trait_datasets

  has_one :submission,
          ->(plant_trial) { trial.where(user_id: plant_trial.user_id) },
          foreign_key: :submitted_object_id,
          dependent: :destroy

  has_attached_file :layout

  validates :plant_trial_name, presence: true, uniqueness: true
  validates :project_descriptor,
            :plant_trial_description,
            :institute_id,
            :trial_year,
            :place_name, presence: true
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
  def scoring_table_data(user_id: nil, extended: false)
    ts = TraitScore.arel_table

    psu_subquery = PlantScoringUnit.visible(user_id)
    td_subquery = TraitDescriptor.visible(user_id)
    pa_subquery = PlantAccession.visible(user_id)
    if extended
      pl_subquery = PlantLine.visible(user_id)
      df_subquery = DesignFactor.visible(user_id)
    end

    all_scores = TraitScore.
      joins {
        [
          psu_subquery.as('plant_scoring_units').on { plant_scoring_unit_id == plant_scoring_units.id }.outer,
          pa_subquery.as('plant_accessions').on { plant_accessions.id == plant_scoring_units.plant_accession_id }.outer,
          td_subquery.as('trait_descriptors').on { trait_descriptor_id == trait_descriptors.id }.outer
        ] +
        (
          extended ? [
            pl_subquery.as('plant_lines').on { plant_lines.id == plant_accessions.plant_line_id }.outer,
            df_subquery.as('design_factors').on { design_factors.id == plant_scoring_units.design_factor_id }.outer
          ] : []
        )
      }
    all_scores = all_scores.
      where(plant_scoring_units: { plant_trial_id: self.id }).
      where(ts[:user_id].eq(user_id).or(ts[:published].eq(true))).
      order('plant_scoring_units.scoring_unit_name asc, trait_descriptors.id asc').
      group_by(&:plant_scoring_unit_id)

    plant_scoring_units.visible(user_id).order('scoring_unit_name asc').map do |plant_scoring_unit|
      scores = all_scores[plant_scoring_unit.id] || []
      plant_accession = plant_scoring_unit.plant_accession
      plant_line = extended ? plant_scoring_unit.plant_accession.try(:plant_line) : nil

      [plant_scoring_unit.scoring_unit_name,
       plant_accession.try(:plant_accession)] +
        (
          extended ? [
            plant_accession.try(:plant_line).try(:plant_line_name),
            (plant_accession.try(:plant_variety) || plant_line.try(:plant_variety)).try(:plant_variety_name),
            plant_accession.try(:plant_accession_derivation),
            plant_accession.try(:originating_organisation),
            plant_accession.try(:year_produced),
            plant_accession.try(:date_harvested),
            plant_scoring_unit.number_units_scored,
            plant_scoring_unit.scoring_unit_sample_size,
            plant_scoring_unit.scoring_unit_frame_size,
            plant_scoring_unit.design_factor.try(:design_factors),
            plant_scoring_unit.date_planted
          ] : []
        ) +
        trait_descriptors.pluck(:id).map do |td_id|
          scores_for_trait = scores.select{ |s| s.trait_descriptor_id == td_id.to_i}
          (1..replicate_numbers[td_id.to_i]).map do |replicate_number|
            replicate = scores_for_trait.detect{ |s| s.technical_replicate_number == replicate_number }
            replicate ? replicate.score_value : '-'
          end
        end.flatten +
        [plant_scoring_unit.id]
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
