class TraitDescriptor < ActiveRecord::Base

  has_many :trait_grades
  has_many :trait_scores
  has_many :processed_trait_datasets

  def self.table_data(params = nil)
    count = 'count(trait_scores.score_value)'
    includes(trait_scores: { plant_scoring_unit: { plant_trial: [:country, { plant_population: :taxonomy_term }]}}).
      group(table_columns).
      order('taxonomy_terms.name, plant_trials.project_descriptor').
      pluck(*(table_columns + [count]))
  end

  def self.table_columns
    [
      'taxonomy_terms.name',
      'plant_populations.name',
      :descriptor_name,
      'plant_trials.project_descriptor',
      'countries.country_name'
    ]
  end
end
