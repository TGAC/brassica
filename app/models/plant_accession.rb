class PlantAccession < ActiveRecord::Base
  belongs_to :plant_line
  belongs_to :user

  has_many :plant_scoring_units

  validates :plant_accession,
            presence: true,
            uniqueness: true

  validates :year_produced,
            length: { is: 4 },
            allow_blank: true

  scope :visible, ->() {
    uid = User.current_user_id
    if uid.present?
      where("published = 't' OR user_id = #{uid}")
    else
      where("published = 't'")
    end
  }

  include Relatable
  include Filterable
  include Pluckable
  include Publishable

  def self.table_data(params = nil)
    uid = User.current_user_id
    pa = PlantAccession.arel_table
    query = (params && params[:query].present?) ? filter(params) : all
    query = query.where(pa[:user_id].eq(uid).or(pa[:published].eq(true)))
    query.pluck_columns
  end

  def self.table_columns
    [
      'plant_accession',
      'plant_lines.plant_line_name',
      'plant_accession_derivation',
      'accession_originator',
      'originating_organisation',
      'year_produced',
      'date_harvested'
    ]
  end

  def self.count_columns
    [
      'plant_scoring_units_count'
    ]
  end

  def self.permitted_params
    [
      query: params_for_filter(table_columns) +
        [
          'id'
        ]
    ]
  end

  def self.ref_columns
    [
      'plant_line_id'
    ]
  end

  include Annotable
end
