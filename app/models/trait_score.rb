class TraitScore < ActiveRecord::Base

  belongs_to :plant_scoring_unit
  belongs_to :scoring_occasion
  belongs_to :trait_descriptor, counter_cache: true

  validates :scoring_occasion_name,
            presence: true

  include Filterable
  include Pluckable

  def self.table_data(params = nil)
    query = (params && params[:query].present?) ? filter(params) : all
    query.pluck_columns
  end

  def self.table_columns
    [
      'scoring_occasion_name',
      'score_value',
      'value_type'
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
