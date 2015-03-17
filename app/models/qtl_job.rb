class QtlJob < ActiveRecord::Base
  self.table_name = 'qtl_jobs'

  has_many :qtls
  
end
