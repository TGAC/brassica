class Qtl < ActiveRecord::Base
  self.table_name = 'qtl'

  belongs_to :processed_trait_dataset
  belongs_to :linkage_group
  belongs_to :qtl_job

  validates :qtl_rank,
            presence: true

  validates :map_qtl_label,
            presence: true

  validates :qtl_mid_position,
            presence: true

  validates :additive_effect,
            presence: true

  include Filterable

  def self.table_data(params = nil)
    query = (params && params[:query].present?) ? filter(params) : all
    query.includes(processed_trait_dataset: :trait_descriptor).
          includes(linkage_group: { linkage_maps: { plant_population: :taxonomy_term }}).
          pluck(*(table_columns + ref_columns))
  end

  def self.table_columns
    [
      'taxonomy_terms.name',
      'plant_populations.name',
      'linkage_maps.linkage_map_label',
      'trait_descriptors.descriptor_name',
      'qtl_rank',
      'map_qtl_label',
      'outer_interval_start',
      'inner_interval_start',
      'qtl_mid_position',
      'inner_interval_end',
      'outer_interval_end',
      'peak_value',
      'peak_p_value',
      'regression_p',
      'residual_p',
      'additive_effect',
      'genetic_variance_explained'
    ]
  end

  def self.ref_columns
    [
      'pubmed_id',
      'plant_populations.id',
      'linkage_maps.id',
      'trait_descriptors.id'
    ]
  end

  def self.permitted_params
    [
      query: [
        'processed_trait_datasets.trait_descriptor_id'
      ]
    ]
  end

  include Annotable
end
