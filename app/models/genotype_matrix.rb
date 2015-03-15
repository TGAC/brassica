class GenotypeMatrix < ActiveRecord::Base

  belongs_to :linkage_map, foreign_key: 'linkage_map_id'

end
