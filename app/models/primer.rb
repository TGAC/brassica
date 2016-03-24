class Primer < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :user

  has_many :marker_assays_a,
           class_name: 'MarkerAssay',
           foreign_key: 'primer_a_id'
  has_many :marker_assays_b,
           class_name: 'MarkerAssay',
           foreign_key: 'primer_b_id'

  validates :primer,
            presence: true,
            uniqueness: true

  validates :sequence,
            presence: true

  validates_with PublicationValidator

  def marker_assays
    marker_assays_a | marker_assays_b
  end

  after_update { marker_assays_a.each(&:touch) }
  after_update { marker_assays_b.each(&:touch) }

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
          'id'
        ]
    ]
  end

  include Annotable
end
