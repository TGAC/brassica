class PopulationLocus < ActiveRecord::Base
  self.table_name = 'population_loci'

  belongs_to :plant_population
  belongs_to :marker_assay, foreign_key: 'marker_assay_name'

  has_many :map_positions, foreign_key: 'mapping_locus'
  has_many :map_locus_hits, foreign_key: 'mapping_locus'

end
