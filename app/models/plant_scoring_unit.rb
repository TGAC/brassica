class PlantScoringUnit < ActiveRecord::Base
  belongs_to :design_factor
  belongs_to :plant_trial, counter_cache: true, touch: true
  belongs_to :plant_accession, counter_cache: true, touch: true
  belongs_to :user

  has_many :trait_scores, dependent: :destroy

  validates :scoring_unit_name, presence: true

  include Relatable
  include Filterable
  include Pluckable
  include Publishable
  include TableData

  def self.table_columns
    [
      'scoring_unit_name',
      'number_units_scored',
      'scoring_unit_sample_size',
      'scoring_unit_frame_size',
      'date_planted',
      'plant_trials.plant_trial_name',
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
    { include: [:design_factor] }
  end

  include Annotable
end
