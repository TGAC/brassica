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
    includes(trait_scores: { plant_scoring_unit: { plant_trial: [:country, { plant_population: :taxonomy_term }]}}).
      group(table_columns + ref_columns).
      order('taxonomy_terms.name, plant_trials.project_descriptor').
      pluck(*(table_columns + ref_columns))
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
