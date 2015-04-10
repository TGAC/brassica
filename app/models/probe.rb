class Probe < ActiveRecord::Base

  has_many :marker_assays, foreign_key: 'probe_name'

  include Annotable
end
