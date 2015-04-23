class TraitScore < ActiveRecord::Base

  belongs_to :plant_scoring_unit
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
      'scoring_date'
    ]
  end

  private

  def self.permitted_params
    [
      query: [
        'trait_descriptors.descriptor_name'
      ]
    ]
  end

  include Annotable
end
