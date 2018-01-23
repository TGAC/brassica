class TraitScore < ApplicationRecord
  belongs_to :plant_scoring_unit, counter_cache: true, touch: true
  belongs_to :trait_descriptor, counter_cache: true, touch: true
  belongs_to :user

  validates :score_value, :plant_scoring_unit_id, :trait_descriptor_id, presence: true

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
    t_subquery = Trait.all

    query = all.
      joins("LEFT OUTER JOIN #{psu_subquery.as('plant_scoring_units').to_sql} ON plant_scoring_unit_id = plant_scoring_units.id").
      joins("LEFT OUTER JOIN #{pt_subquery.as('plant_trials').to_sql} ON plant_scoring_units.plant_trial_id = plant_trials.id").
      joins("LEFT OUTER JOIN #{pp_subquery.as('plant_populations').to_sql} ON plant_trials.plant_population_id = plant_populations.id").
      joins("LEFT OUTER JOIN #{pa_subquery.as('plant_accessions').to_sql} ON plant_scoring_units.plant_accession_id = plant_accessions.id").
      joins("LEFT OUTER JOIN #{pl_subquery.as('plant_lines').to_sql} ON plant_accessions.plant_line_id = plant_lines.id").
      joins("LEFT OUTER JOIN #{td_subquery.as('trait_descriptors').to_sql} ON trait_descriptor_id = trait_descriptors.id").
      joins("LEFT OUTER JOIN #{t_subquery.as('traits').to_sql} ON trait_descriptors.trait_id = traits.id")

    query = (params && (params[:query] || params[:fetch])) ? filter(params, query) : query
    query = query.where(arel_table[:user_id].eq(uid).or(arel_table[:published].eq(true)))
    query.pluck(*(table_columns + ref_columns))
  end

  def self.table_columns
    [
      'plant_trials.plant_trial_name',
      'plant_populations.name',
      'plant_lines.plant_line_name',
      'traits.name',
      'score_value',
      'trait_descriptors.units_of_measurements',
      'technical_replicate_number',
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
          'trait_descriptors.id',
          'plant_scoring_units.plant_trial_id',
          'plant_scoring_units.id',
          'user_id',
          'id'
        ]
    ]
  end

  include Annotable
end
