class QtlJob < ActiveRecord::Base

  has_many :qtls

  validates :qtl_job_name,
            presence: true,
            uniqueness: true

  validates :linkage_map_id,
            presence: true

  validates :qtl_software,
            presence: true

  validates :qtl_method,
            presence: true

  include Relatable
  include Filterable
  include Pluckable

  def self.table_data(params = nil)
    query = (params && params[:query].present?) ? filter(params) : all
    query.pluck_columns
  end

  def self.table_columns
    [
      'qtl_job_name',
      # TODO FIXME this has to await fixing #205
      # 'linkage_map_id',
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
      query: [
        'id'
      ]
    ]
  end

  include Annotable
end
