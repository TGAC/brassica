module CommonHelpers
  # All model tables that _should_ include Annotable
  def annotable_tables
    %w(
      design_factors
      genotype_matrices
      linkage_groups
      linkage_maps
      map_positions
      marker_assays
      marker_sequence_assignments
      plant_accessions
      plant_lines
      plant_parts
      plant_populations
      plant_scoring_units
      plant_trials
      population_loci
      primers
      processed_trait_datasets
      qtl
      qtl_jobs
      scoring_occasions
      trait_descriptors
      trait_scores

      plant_population_lists
      plant_varieties
      probes
      trait_grades
    )
  end

  # All model tables that are displayed in data tables
  def displayable_tables
    annotable_tables.select do |table|
      model_klass = table.singularize.camelize.constantize
      model_klass.respond_to? :table_columns
    end
  end
end