class Primer < ActiveRecord::Base

  has_many :marker_assays_a,
           class_name: 'MarkerAssay',
           foreign_key: 'primer_a_id'
  has_many :marker_assays_b,
           class_name: 'MarkerAssay',
           foreign_key: 'primer_b_id'

  validates :primer,
            presence: true

  validates :sequence,
            presence: true

  validates :sequence_id,
            presence: true

  validates :sequence_source_acronym,
            presence: true

  def marker_assays
    marker_assays_a | marker_assays_b
  end

  include Relatable
  include Filterable
  include Pluckable

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

  private

  def self.permitted_params
    [
      query: [
        'id'
      ]
    ]
  end

  include Annotable
end
