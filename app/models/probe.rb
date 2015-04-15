class Probe < ActiveRecord::Base

  has_many :marker_assays

  include Annotable

  validates :probe_name,
            presence: true

  validates :species,
            presence: true

  validates :clone_name,
            presence: true

  validates :sequence_id,
            presence: true

  validates :sequence_source_acronym,
            presence: true
end
