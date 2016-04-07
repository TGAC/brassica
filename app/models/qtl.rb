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

  def self.table_data(params = nil, uid = nil)
    qtlt = Qtl.arel_table

    td_subquery = TraitDescriptor.visible(uid)
    lg_subquery = LinkageGroup.visible(uid)
    lm_subquery = LinkageMap.visible(uid)
    pp_subquery = PlantPopulation.visible(uid)
    qtlj_subquery = QtlJob.visible(uid)

    query = (params && (params[:query] || params[:fetch])) ? filter(params) : all

    query = query.
      joins {[
        processed_trait_dataset,
        td_subquery.as('trait_descriptors').on { processed_trait_datasets.trait_descriptor_id == trait_descriptors.id }.outer,
        lg_subquery.as('linkage_groups').on { linkage_group_id == linkage_groups.id }.outer,
        lm_subquery.as('linkage_maps').on { linkage_groups.linkage_map_id == linkage_maps.id }.outer,
        pp_subquery.as('plant_populations').on { linkage_maps.plant_population_id == plant_populations.id }.outer,
        qtlj_subquery.as('qtl_jobs').on { qtl_job_id == qtl_jobs.id }.outer
      ]}
    query = query.where(qtlt[:user_id].eq(uid).or(qtlt[:published].eq(true)))
    query.pluck(*(table_columns + ref_columns))
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
