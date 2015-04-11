class Qtl < ActiveRecord::Base
  self.table_name = 'qtl'

  belongs_to :processed_trait_dataset
  belongs_to :linkage_group
  belongs_to :qtl_job

  # CREATE TABLE aux_qtl_interface
  # AS (SELECT distinct pp.species as Species,
  #   canonical_population_name as Population,
  #   lm.linkage_map_id as 'Linkage Map',
  #   descriptor_name as 'Trait name',
  #   count_scores as 'count scores',
  #   count(qtl_rank) as 'countQTL'
  # FROM qtl q
  # inner join processed_trait_datasets ptd on ptd.processed_trait_dataset_id = q.processed_trait_dataset_id
  # inner join map_linkage_group_lists mlgl on mlgl.linkage_group_id=q.linkage_group_id
  # inner join linkage_maps lm on mlgl.linkage_map_id=lm.linkage_map_id
  # inner join plant_populations pp on pp.plant_population_id = lm.mapping_population
  # inner join trait_descriptors td on ptd.trait_descriptor_id=td.trait_descriptor_id
  # left join auxTraitsInterface aTI on td.descriptor_name = aTI.Trait_name
  # WHERE descriptor_name NOT IN ('not applicable','unspecified','none')
  # group by canonical_population_name, descriptor_name);

  # SELECT taxonomy_terms.name, plant_populations.name, linkage_maps.linkage_map_label, trait_descriptors.descriptor_name,
  #        sum(trait_descriptors.trait_scores_count), count(qtl_rank) FROM "qtl"
  # INNER JOIN "processed_trait_datasets" ON "processed_trait_datasets"."id" = "qtl"."processed_trait_dataset_id"
  # INNER JOIN "trait_descriptors" ON "trait_descriptors"."id" = "processed_trait_datasets"."trait_descriptor_id"
  # INNER JOIN "linkage_groups" ON "linkage_groups"."id" = "qtl"."linkage_group_id"
  # INNER JOIN "map_linkage_group_lists" ON "map_linkage_group_lists"."linkage_group_id" = "linkage_groups"."id"
  # INNER JOIN "linkage_maps" ON "linkage_maps"."id" = "map_linkage_group_lists"."linkage_map_id"
  # INNER JOIN "plant_populations" ON "plant_populations"."id" = "linkage_maps"."plant_population_id"
  # INNER JOIN "taxonomy_terms" ON "taxonomy_terms"."id" = "plant_populations"."taxonomy_term_id"
  # GROUP BY taxonomy_terms.name, plant_populations.name, linkage_maps.linkage_map_label, trait_descriptors.descriptor_name

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
end
