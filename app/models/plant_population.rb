class PlantPopulation < ActiveRecord::Base

  belongs_to :taxonomy_term

  belongs_to :population_type_lookup, foreign_key: 'population_type'

  belongs_to :male_parent_line, class_name: 'PlantLine',
             foreign_key: 'male_parent_line'

  belongs_to :female_parent_line, class_name: 'PlantLine',
             foreign_key: 'female_parent_line'

  has_many :plant_population_lists, foreign_key: 'plant_population_id'

  has_many :linkage_maps, foreign_key: 'mapping_population'

  has_many :population_loci, foreign_key: 'plant_population'

  has_many :processed_trait_datasets, foreign_key: 'population_id'

  has_and_belongs_to_many :plant_lines,
                          join_table: 'plant_population_lists',
                          foreign_key: 'plant_population_id',
                          association_foreign_key: 'plant_line_name'

  # Exlude the ['none', 'unspecified', 'not applicable'] pseudo-record trio
  scope :drop_dummies, -> do
    where.not(canonical_population_name: '')
  end

  def self.grouped(columns: nil, count: nil)
    columns ||= [
      'plant_populations.plant_population_id',
      'taxonomy_terms.name',
      :canonical_population_name,
      :female_parent_line,
      :male_parent_line,
      :population_type
    ]

    count = 'count(plant_lines.plant_line_name)'

    includes(:plant_lines).
    joins(:taxonomy_term).
    group(columns).
    drop_dummies.
    order(:plant_population_id).
    pluck(*(columns + [count]))
  end
end
