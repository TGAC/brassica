class PopulationLocus < ActiveRecord::Base

  belongs_to :plant_population
  belongs_to :marker_assay

  has_many :map_positions
  has_many :map_locus_hits

  validates :plant_population,
            presence: true

  validates :mapping_locus,
            presence: true

  include Annotable
end
