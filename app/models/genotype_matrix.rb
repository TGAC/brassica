class GenotypeMatrix < ActiveRecord::Base

  belongs_to :linkage_map

  include Annotable
end
