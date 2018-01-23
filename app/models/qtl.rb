class Qtl < ApplicationRecord
  self.table_name = 'qtl'

  belongs_to :processed_trait_dataset
  belongs_to :linkage_group, counter_cache: true, touch: true
  belongs_to :qtl_job, counter_cache: true, touch: true
  belongs_to :user

  validates :qtl_rank, :map_qtl_label, :qtl_mid_position,
            presence: true

  include Filterable
  include Searchable
  include Publishable

  def self.table_data(params = nil, uid = nil)
    t_subquery = Trait.all
    td_subquery = TraitDescriptor.visible(uid)
    lg_subquery = LinkageGroup.visible(uid)
    lm_subquery = LinkageMap.visible(uid)
    pp_subquery = PlantPopulation.visible(uid)
    qtlj_subquery = QtlJob.visible(uid)

    query = all.
      joins(:processed_trait_dataset).
      joins("LEFT OUTER JOIN #{td_subquery.as('trait_descriptors').to_sql} ON processed_trait_datasets.trait_descriptor_id = trait_descriptors.id").
      joins("LEFT OUTER JOIN #{t_subquery.as('traits').to_sql} ON trait_descriptors.trait_id = traits.id").
      joins("LEFT OUTER JOIN #{lg_subquery.as('linkage_groups').to_sql} ON qtl.linkage_group_id = linkage_groups.id").
      joins("LEFT OUTER JOIN #{lm_subquery.as('linkage_maps').to_sql} ON linkage_groups.linkage_map_id = linkage_maps.id").
      joins("LEFT OUTER JOIN #{pp_subquery.as('plant_populations').to_sql} ON linkage_maps.plant_population_id = plant_populations.id").
      joins("LEFT OUTER JOIN #{qtlj_subquery.as('qtl_jobs').to_sql} ON qtl.qtl_job_id = qtl_jobs.id")

    query = (params && (params[:query] || params[:fetch])) ? filter(params, query) : query
    query = query.where(arel_table[:user_id].eq(uid).or(arel_table[:published].eq(true)))
    query.pluck(*(table_columns + ref_columns))
  end

  def self.table_columns
    [
      'traits.name',
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
          'user_id',
          'id'
        ]
    ]
  end

  def self.indexed_json_structure
    {
      only: numeric_columns.map(&:to_sym) | [:map_qtl_label],
      include: {
        linkage_group: {
          only: :linkage_group_label
        },
        processed_trait_dataset: {
          only: [],
          include: {
            trait_descriptor: {
              only: [],
              include: { trait: { only: :name }}
            }
          }
        }
      }
    }
  end

  mapping dynamic: 'false' do
    indexes :map_qtl_label
    indexes :linkage_group do
      indexes :linkage_group_label
    end
    indexes :processed_trait_dataset do
      indexes :trait_descriptor do
        indexes :trait do
          indexes :name
        end
      end
    end

    Qtl.numeric_columns.each do |column|
      indexes column, include_in_all: 'false'
    end
  end

  include Annotable
end
