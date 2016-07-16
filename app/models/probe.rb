class Probe < ActiveRecord::Base
  belongs_to :taxonomy_term
  belongs_to :user

  after_update { marker_assays.each(&:touch) }
  before_destroy { marker_assays.each(&:touch) }

  has_many :marker_assays

  validates :probe_name,
            presence: true,
            uniqueness: true

  validates :clone_name, :sequence_id, :sequence_source_acronym,
            presence: true

  include Searchable
  include Relatable
  include Filterable
  include Pluckable
  include Publishable
  include TableData

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
          'user_id',
          'id'
        ]
    ]
  end

  include Annotable
end
