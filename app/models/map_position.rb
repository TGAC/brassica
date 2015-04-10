class MapPosition < ActiveRecord::Base

  belongs_to :linkage_group

  belongs_to :population_locus

  has_many :map_locus_hits, foreign_key: 'map_position'

  include Annotable
end
