class Qtl < ActiveRecord::Base
  self.table_name = 'qtl'

  belongs_to :processed_trait_dataset
  belongs_to :linkage_group
  belongs_to :qtl_job

  def self.table_data(params = nil)
    joins(processed_trait_dataset: :trait_descriptor).
      joins(linkage_group: { linkage_maps: { plant_population: :taxonomy_term }}).
      group(table_columns).
      pluck(*(table_columns + count_columns))
  end

  def self.table_columns
    [
      'taxonomy_terms.name',
      'plant_populations.name',
      'linkage_maps.linkage_map_label',
      'trait_descriptors.descriptor_name'
    ]
  end

  def self.count_columns
    [
      'sum(trait_descriptors.trait_scores_count)',
      'count(qtl.id)'
    ]
  end

  include Annotable
end
