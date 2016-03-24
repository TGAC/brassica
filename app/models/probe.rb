class Probe < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :taxonomy_term
  belongs_to :user

  has_many :marker_assays

  validates :probe_name,
            presence: true,
            uniqueness: true

  validates :clone_name,
            presence: true

  validates :sequence_id,
            presence: true

  validates :sequence_source_acronym,
            presence: true

  validates_with PublicationValidator

  after_update { marker_assays.each(&:touch) }

  include Searchable
  include Relatable
  include Filterable
  include Pluckable
  include Publishable

  def self.table_data(params = nil)
    query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
    query.pluck_columns
  end

  def self.table_columns
    [
      'taxonomy_terms.name',
      'probe_name',
      'clone_name',
      'date_described',
      'sequence_id',
      'sequence_source_acronym'
    ]
  end

  def self.count_columns
    [
      'marker_assays_count'
    ]
  end

  def self.permitted_params
    [
      :fetch,
      query: params_for_filter(table_columns) +
        [
          'id'
        ]
    ]
  end

  include Annotable
end
