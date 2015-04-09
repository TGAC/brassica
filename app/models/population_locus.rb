class PopulationLocus < ActiveRecord::Base
  self.table_name = 'population_loci'

  belongs_to :plant_population
  belongs_to :marker_assay, foreign_key: 'marker_assay_name'

  has_many :map_positions
  has_many :map_locus_hits

end
