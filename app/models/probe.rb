class Probe < ActiveRecord::Base

  belongs_to :taxonomy_term

  has_many :marker_assays

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

  include Annotable
end
