class PopulationLocus < ActiveRecord::Base
  self.table_name = 'population_loci'

  belongs_to :plant_population, foreign_key: 'plant_population'

  has_many :map_positions, foreign_key: 'mapping_locus'

  has_many :map_locus_hits, foreign_key: 'mapping_locus'

end
