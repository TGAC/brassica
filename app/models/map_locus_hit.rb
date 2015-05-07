class MapLocusHit < ActiveRecord::Base

  belongs_to :linkage_map
  belongs_to :linkage_group
  belongs_to :map_position
  belongs_to :population_locus

  validates :consensus_group_assignment,
            presence: true

  validates :canonical_marker_name,
            presence: true

  validates :associated_sequence_id,
            presence: true

  validates :sequence_source_acronym,
            presence: true
end
