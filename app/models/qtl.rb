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

  include Relatable
  include Pluckable

  def self.table_data(params = nil)
    includes(processed_trait_dataset: :trait_descriptor).
      includes(linkage_group: { linkage_maps: { plant_population: :taxonomy_term }}).
      # group(table_columns[0..-3]).
      # pluck(*table_columns)
      # query = (params && params[:query].present?) ? filter(params) : all
      pluck_columns
  end

  def self.table_columns
    [
      'taxonomy_terms.name',
      # 'plant_populations.name',
      # 'linkage_maps.linkage_map_label',
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

  def self.count_columns
    [
      # 'sum(trait_descriptors.trait_scores_count) AS trait_scores_count'
      'trait_descriptors.trait_scores_count'
    ]
  end

  def self.ref_columns
    [
      'pubmed_id'
    ]
  end

  include Annotable
end
