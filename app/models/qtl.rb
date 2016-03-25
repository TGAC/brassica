class Qtl < ActiveRecord::Base
  self.table_name = 'qtl'

  belongs_to :processed_trait_dataset
  belongs_to :linkage_group, counter_cache: true
  belongs_to :qtl_job, counter_cache: true
  belongs_to :user

  validates :qtl_rank,
            presence: true

  validates :map_qtl_label,
            presence: true

  validates :qtl_mid_position,
            presence: true

  include Filterable
  include Searchable
  include Publishable

  def self.table_data(params = nil)
    query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
    query.includes(processed_trait_dataset: :trait_descriptor).
          includes(:linkage_group).
          includes(linkage_group: { linkage_map: :plant_population }).
          includes(:qtl_job).
          pluck(*(table_columns + ref_columns))
  end

  def self.table_columns
    [
      'trait_descriptors.descriptor_name',
      'map_qtl_label',
      'linkage_groups.linkage_group_label',
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
      'linkage_groups.id',
      'qtl_jobs.id',
      'plant_populations.id',
      'linkage_maps.id',
      'trait_descriptors.id',
      'pubmed_id'
    ]
  end

  def self.numeric_columns
    [
      'qtl_rank',
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

  def self.permitted_params
    [
      :fetch,
      query: params_for_filter(table_columns) +
        [
          'processed_trait_datasets.trait_descriptor_id',
          'qtl_jobs.id',
          'linkage_groups.id',
          'id'
        ]
    ]
  end

  def self.indexed_json_structure
    {
      only: numeric_columns.map(&:to_sym) | [:map_qtl_label],
      include: {
        processed_trait_dataset: {
          only: [],
          include: { trait_descriptor: { only: :descriptor_name } }
        }
      }
    }
  end

  mapping dynamic: 'false' do
    indexes :map_qtl_label
    indexes :processed_trait_dataset do
      indexes :trait_descriptor do
        indexes :descriptor_name
      end
    end

    Qtl.numeric_columns.each do |column|
      indexes column, include_in_all: 'false'
    end
  end

  include Annotable
end
