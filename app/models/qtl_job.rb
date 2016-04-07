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
  include TableData

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
