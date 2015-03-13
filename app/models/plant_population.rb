class PlantPopulation < ActiveRecord::Base

  belongs_to :population_type_lookup, foreign_key: 'population_type'

  belongs_to :male_parent_line, class_name: 'PlantLine',
             foreign_key: 'male_parent_line'

  belongs_to :female_parent_line, class_name: 'PlantLine',
             foreign_key: 'female_parent_line'

  has_many :plant_population_lists, foreign_key: 'plant_population_id'

  has_and_belongs_to_many :plant_lines,
                          join_table: 'plant_population_lists',
                          foreign_key: 'plant_population_id',
                          association_foreign_key: 'plant_line_name'

  # Exlude the ['none', 'unspecified', 'not applicable'] pseudo-record trio
  scope :drop_dummies, -> do
    where.not(canonical_population_name: '')
  end

  # Original CropStore query
  # plant_populations.species as Species,
  # plant_populations.canonical_population_name as Population,
  # plant_populations.female_parent_line as 'Female Parent',
  # plant_populations.male_parent_line as 'Male Parent',
  # plant_populations.population_type as Type,
  # count( plant_population_id ) as 'Number Of Subpopulations' ,
  # count( linkage_maps.mapping_population ) as 'Number Of Maps'
  # FROM plant_populations
  # LEFT JOIN pop_type_lookup ON pop_type_lookup.population_type=plant_populations.population_type
  # LEFT JOIN linkage_maps ON linkage_maps.mapping_population = plant_populations.plant_population_id
  # GROUP BY plant_populations.canonical_population_name
  # ORDER BY canonical_population_name
  def self.grid_data
    columns = [
      :species,
      :canonical_population_name,
      :female_parent_line,
      :male_parent_line,
      :population_type
    ]

    select(columns).
    drop_dummies.
    group(columns).
    order(:canonical_population_name).
    count(:plant_population_id)
  end
end
