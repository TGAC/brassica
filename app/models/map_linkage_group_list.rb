class MapLinkageGroupList < ActiveRecord::Base

  belongs_to :linkage_map, counter_cache: true
  belongs_to :linkage_group, counter_cache: true

end
