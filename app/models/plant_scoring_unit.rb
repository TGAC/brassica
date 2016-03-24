class PlantScoringUnit < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :design_factor
  belongs_to :plant_trial, counter_cache: true
  belongs_to :plant_accession, counter_cache: true
  belongs_to :plant_part
  belongs_to :user

  has_many :trait_scores, dependent: :destroy

  validates :scoring_unit_name,
            presence: true

  validates_with PublicationValidator

  include Relatable
  include Filterable
  include Pluckable

  def self.table_data(params = nil)
    query = (params && params[:query].present?) ? filter(params) : all
    query.pluck_columns
  end

  def self.table_columns
    [
      'scoring_unit_name',
      'number_units_scored',
      'scoring_unit_sample_size',
      'scoring_unit_frame_size',
      'date_planted',
      'plant_trials.plant_trial_name',
      'plant_parts.plant_part',
      'plant_accessions.plant_accession'
    ]
  end

  def self.count_columns
    [
      'trait_scores_count'
    ]
  end

  def self.permitted_params
    [
      query: params_for_filter(table_columns) +
        [
          'plant_trials.id',
          'plant_accessions.id',
          'id'
        ]
    ]
  end

  def self.ref_columns
    [
      'plant_accessions.id',
      'plant_trials.id'
    ]
  end

  def self.json_options
    { include: [:design_factor, :plant_part] }
  end

  def published?
    updated_at < Time.now - 1.week
  end

  include Annotable
end
