class TraitDescriptor < ActiveRecord::Base

  has_many :trait_grades
  has_many :trait_scores
  has_many :processed_trait_datasets

  validates :descriptor_label,
            presence: true

  validates :category,
            presence: true

  validates :descriptor_name,
            presence: true

  validates :where_to_score,
            presence: true

  validates :trait_scores_count,
            presence: true,
            numericality: true

  def self.table_data(params = nil)
    connection.execute(
      'SELECT tt.name, pp.name, td.descriptor_name, pt.project_descriptor, c.country_name, cnt, tdid
       FROM plant_trials pt JOIN

       (SELECT trait_descriptor_id AS tdid, plant_trial_id AS ptid, COUNT(*) AS cnt FROM
       (SELECT * FROM trait_scores JOIN plant_scoring_units ON trait_scores.plant_scoring_unit_id = plant_scoring_units.id) AS core
       GROUP BY trait_descriptor_id, plant_trial_id) AS intable

        ON intable.ptid = pt.id
        JOIN plant_populations pp ON pt.plant_population_id = pp.id
        JOIN trait_descriptors td ON intable.tdid = td.id
        JOIN countries c ON pt.country_id = c.id
        JOIN taxonomy_terms tt ON pp.taxonomy_term_id = tt.id

        ORDER BY tt.name, pt.project_descriptor;'
    ).values
  end

  def self.table_columns
    [
      'taxonomy_terms.name',
      'plant_populations.name',
      'descriptor_name',
      'plant_trials.project_descriptor',
      'countries.country_name',
      'trait_scores_count'
    ]
  end

  include Annotable
end
