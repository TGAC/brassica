class Primer < ApplicationRecord
  belongs_to :user

  after_update { marker_assays_a.each(&:touch) }
  after_update { marker_assays_b.each(&:touch) }
  before_destroy { marker_assays_a.each(&:touch) }
  before_destroy { marker_assays_b.each(&:touch) }

  has_many :marker_assays_a,
           class_name: 'MarkerAssay',
           foreign_key: 'primer_a_id'
  has_many :marker_assays_b,
           class_name: 'MarkerAssay',
           foreign_key: 'primer_b_id'

  validates :primer, presence: true, uniqueness: true
  validates :sequence, presence: true

  def marker_assays
    marker_assays_a | marker_assays_b
  end

  include Searchable
  include Relatable
  include Filterable
  include Pluckable
  include Publishable
  include TableData

  def self.table_columns
    [
      'primer',
      'sequence',
      'sequence_id',
      'sequence_source_acronym',
      'description'
    ]
  end

  def self.count_columns
    [
      'marker_assays_a_count',
      'marker_assays_b_count'
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
