class TraitScore < ActiveRecord::Base
  belongs_to :plant_scoring_unit, counter_cache: true
  belongs_to :trait_descriptor, counter_cache: true
  belongs_to :user

  validates :score_value,
            presence: true

  include Filterable
  include Pluckable
  include Publishable

  scope :of_trial, ->(plant_trial_id) {
    joins(:plant_scoring_unit).
    where(plant_scoring_units: { plant_trial_id: plant_trial_id })
  }

  def self.table_data(params = nil, uid = nil)
    psu_subquery = PlantScoringUnit.visible(uid)
    pt_subquery = PlantTrial.visible(uid)
    pp_subquery = PlantPopulation.visible(uid)
    pa_subquery = PlantAccession.visible(uid)
    pl_subquery = PlantLine.visible(uid)
    td_subquery = TraitDescriptor.visible(uid)

    query = all
    query = query.joins {[
      psu_subquery.as('plant_scoring_units').on { plant_scoring_unit_id == plant_scoring_units.id }.outer,
      pt_subquery.as('plant_trials').on { plant_scoring_units.plant_trial_id == plant_trials.id }.outer,
      pp_subquery.as('plant_populations').on { plant_trials.plant_population_id == plant_populations.id }.outer,
      pa_subquery.as('plant_accessions').on { plant_scoring_units.plant_accession_id == plant_accessions.id }.outer,
      pl_subquery.as('plant_lines').on { plant_accessions.plant_line_id == plant_lines.id }.outer,
      td_subquery.as('trait_descriptors').on { trait_descriptor_id == trait_descriptors.id }.outer
    ]}

    query = (params && (params[:query] || params[:fetch])) ? filter(params, query) : query
    query = query.where(arel_table[:user_id].eq(uid).or(arel_table[:published].eq(true)))
    query.pluck(*(table_columns + ref_columns))
  end

  def self.table_columns
    [
      'plant_trials.plant_trial_name',
      'plant_populations.name',
      'plant_lines.plant_line_name',
      'trait_descriptors.descriptor_name',
      'score_value',
      'trait_descriptors.units_of_measurements',
      'value_type',
      'scoring_date',
      'plant_scoring_units.scoring_unit_name'
    ]
  end

  def self.ref_columns
    [
      'plant_populations.id',
      'plant_lines.id',
      'plant_trials.id',
      'trait_descriptors.id',
      'plant_scoring_units.id'
    ]
  end

  def self.permitted_params
    [
      query: params_for_filter(table_columns) +
        [
          'trait_descriptor_id',
          'plant_scoring_units.plant_trial_id',
          'plant_scoring_units.id',
          'id'
        ]
    ]
  end

  include Annotable
end
