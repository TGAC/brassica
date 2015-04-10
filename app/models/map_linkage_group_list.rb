class MapLinkageGroupList < ActiveRecord::Base

  belongs_to :linkage_map
  belongs_to :linkage_group

end
