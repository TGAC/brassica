class TraitScore < ActiveRecord::Base

  belongs_to :plant_scoring_unit, counter_cache: true
  belongs_to :trait_descriptor, counter_cache: true

  include Filterable
  include Pluckable

  def self.table_data(params = nil)
    query = (params && params[:query].present?) ? filter(params) : all
    query.pluck_columns
  end

  def self.table_columns
    [
      'score_value',
      'value_type',
      'scoring_date',
      'plant_scoring_units.scoring_unit_name'
    ]
  end

  def self.ref_columns
    [
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
