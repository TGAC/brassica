class TraitDescriptor < ActiveRecord::Base

  belongs_to :user

  has_many :trait_grades
  has_many :trait_scores
  has_many :processed_trait_datasets

  validates :category,
            presence: true

  validates :descriptor_name,
            presence: true

  after_update { processed_trait_datasets.each(&:touch) }

  include Searchable

  def self.table_data(params = nil)
    trait_descriptor_query = ''
    if params && params[:query].present? && params[:query][:id].present?
      trait_descriptor_query = "WHERE td.id = #{params[:query][:id].to_i}"
    elsif params && params[:fetch].present?
      ids = Search.new(params[:fetch]).send(table_name).records.map(&:id)
      trait_descriptor_query = "WHERE td.id IN (#{ids.join(',')})"
    end
    connection.execute(
      'SELECT tt.name, pp.name, td.descriptor_name, pt.project_descriptor, c.country_name, cnt, qtlcnt, pp.id, pt.id, td.id
        FROM
        trait_descriptors td
        LEFT OUTER JOIN
          (SELECT trait_descriptor_id AS tdid, plant_trial_id AS ptid, COUNT(*) AS cnt FROM
          (SELECT * FROM trait_scores JOIN plant_scoring_units ON trait_scores.plant_scoring_unit_id = plant_scoring_units.id) AS core
          GROUP BY trait_descriptor_id, plant_trial_id) AS intable
        ON intable.tdid = td.id
        LEFT OUTER JOIN plant_trials pt ON intable.ptid = pt.id
        LEFT OUTER JOIN plant_populations pp ON pt.plant_population_id = pp.id
        LEFT OUTER JOIN countries c ON pt.country_id = c.id
        LEFT OUTER JOIN taxonomy_terms tt ON pp.taxonomy_term_id = tt.id
        LEFT OUTER JOIN (
          SELECT td.id AS tdid2, COUNT(qtl.id) AS qtlcnt FROM
          trait_descriptors td
          LEFT OUTER JOIN processed_trait_datasets ptd ON ptd.trait_descriptor_id = td.id
          LEFT OUTER JOIN qtl ON qtl.processed_trait_dataset_id = ptd.id
          GROUP BY td.id
        ) AS intable2
        ON td.id = tdid2 ' +
        trait_descriptor_query +
        ' ORDER BY tt.name, pt.project_descriptor;'
    ).values
  end

  def self.table_columns
    [
      'taxonomy_terms.name',
      'plant_populations.name',
      'descriptor_name',
      'plant_trials.project_descriptor',
      'countries.country_name',
      'trait_scores_count',
      'qtl_count'
    ]
  end

  def self.indexed_json_structure
    {
      only: [
        :descriptor_name
      ]
    }
  end

  def self.json_options
    { include: [:trait_grades] }
  end

  def published?
    updated_at < Time.now - 1.week
  end

  include Annotable
end
