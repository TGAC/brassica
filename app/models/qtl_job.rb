class QtlJob < ActiveRecord::Base

  has_many :qtls

  include Annotable

  validates :qtl_job_name,
            presence: true

  validates :linkage_map_id,
            presence: true

  validates :qtl_software,
            presence: true

  validates :qtl_method,
            presence: true
end
