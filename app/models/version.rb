class Version < ActiveRecord::Base

  self.table_name = 'version'

  validates :version,
            presence: true,
            uniqueness: true

  validates :updated_by_whom,
            presence: true
end
