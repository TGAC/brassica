class QtlJob < ActiveRecord::Base
  belongs_to :linkage_map
  belongs_to :user

  has_many :qtls

  validates :qtl_job_name,
            presence: true,
            uniqueness: true

  validates :qtl_software,
            presence: true

  validates :qtl_method,
            presence: true

  include Relatable
  include Filterable
  include Pluckable
  include Publishable

  scope :visible, ->() {
    uid = User.current_user_id
    if uid.present?
      where("published = 't' OR user_id = #{uid}")
    else
      where("published = 't'")
    end
  }

  def self.table_data(params = nil)
    uid = User.current_user_id
    qtlj = QtlJob.arel_table
    query = (params && params[:query].present?) ? filter(params) : all
    query = query.where(qtlj[:user_id].eq(uid).or(qtlj[:published].eq(true)))
    query.pluck_columns
  end

  def self.table_columns
    [
      'qtl_job_name',
      'qtl_software',
      'qtl_method',
      'threshold_specification_method',
      'interval_type',
      'inner_confidence_threshold',
      'outer_confidence_threshold',
      'qtl_statistic_type',
      'date_run'
    ]
  end

  def self.count_columns
    [
      'qtls_count'
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

  include Annotable
end
