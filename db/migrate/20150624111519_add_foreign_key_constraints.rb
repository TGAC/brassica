class AddForeignKeyConstraints < ActiveRecord::Migration
  def change
    add_foreign_key :genotype_matrices, :linkage_maps, on_delete: :nullify, on_update: :cascade

    add_foreign_key :linkage_groups, :linkage_maps, on_delete: :nullify, on_update: :cascade

    add_foreign_key :linkage_maps, :plant_populations, on_delete: :nullify, on_update: :cascade

    add_foreign_key :map_locus_hits, :linkage_maps, on_delete: :nullify, on_update: :cascade
    add_foreign_key :map_locus_hits, :linkage_groups, on_delete: :nullify, on_update: :cascade
    add_foreign_key :map_locus_hits, :population_loci, on_delete: :nullify, on_update: :cascade
    add_foreign_key :map_locus_hits, :map_positions, on_delete: :nullify, on_update: :cascade

    add_foreign_key :map_positions, :linkage_groups, on_delete: :nullify, on_update: :cascade
    add_foreign_key :map_positions, :population_loci, on_delete: :nullify, on_update: :cascade

    add_foreign_key :marker_assays, :restriction_enzymes, column: 'restriction_enzyme_a_id', on_delete: :nullify, on_update: :cascade
    add_foreign_key :marker_assays, :restriction_enzymes, column: 'restriction_enzyme_b_id', on_delete: :nullify, on_update: :cascade
    add_foreign_key :marker_assays, :primers, column: 'primer_a_id', on_delete: :nullify, on_update: :cascade
    add_foreign_key :marker_assays, :primers, column: 'primer_b_id', on_delete: :nullify, on_update: :cascade
    add_foreign_key :marker_assays, :probes, on_delete: :nullify, on_update: :cascade
    add_foreign_key :marker_assays, :marker_sequence_assignments, on_delete: :nullify, on_update: :cascade

    add_foreign_key :plant_accessions, :plant_lines, on_delete: :nullify, on_update: :cascade

    add_foreign_key :plant_lines, :taxonomy_terms, on_delete: :nullify, on_update: :cascade
    if column_exists?(:plant_lines, :plant_variety_id)
      add_foreign_key :plant_lines, :plant_varieties, on_delete: :nullify, on_update: :cascade
    end

    add_foreign_key :plant_population_lists, :plant_lines, on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_population_lists, :plant_populations, on_delete: :nullify, on_update: :cascade

    add_foreign_key :plant_populations, :taxonomy_terms, on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_populations, :plant_lines, column: 'male_parent_line_id', on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_populations, :plant_lines, column: 'female_parent_line_id', on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_populations, :pop_type_lookup, column: 'population_type_id', on_delete: :nullify, on_update: :cascade

    add_foreign_key :plant_scoring_units, :plant_accessions, on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_scoring_units, :plant_trials, on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_scoring_units, :design_factors, on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_scoring_units, :plant_parts, on_delete: :nullify, on_update: :cascade

    add_foreign_key :plant_trials, :countries, on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_trials, :plant_populations, on_delete: :nullify, on_update: :cascade

    add_foreign_key :plant_variety_country_of_origin, :countries, on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_variety_country_of_origin, :plant_varieties, on_delete: :nullify, on_update: :cascade

    add_foreign_key :plant_variety_country_registered, :countries, on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_variety_country_registered, :plant_varieties, on_delete: :nullify, on_update: :cascade

    add_foreign_key :population_loci, :plant_populations, on_delete: :nullify, on_update: :cascade
    add_foreign_key :population_loci, :marker_assays, on_delete: :nullify, on_update: :cascade

    add_foreign_key :probes, :taxonomy_terms, on_delete: :nullify, on_update: :cascade

    add_foreign_key :processed_trait_datasets, :plant_trials, on_delete: :nullify, on_update: :cascade
    add_foreign_key :processed_trait_datasets, :trait_descriptors, on_delete: :nullify, on_update: :cascade

    add_foreign_key :qtl, :processed_trait_datasets, on_delete: :nullify, on_update: :cascade
    add_foreign_key :qtl, :qtl_jobs, on_delete: :nullify, on_update: :cascade
    add_foreign_key :qtl, :linkage_groups, on_delete: :nullify, on_update: :cascade

    add_foreign_key :trait_grades, :trait_descriptors, on_delete: :nullify, on_update: :cascade

    if column_exists?(:trait_scores, :plant_scoring_unit_id)
      add_foreign_key :trait_scores, :plant_scoring_units, on_delete: :nullify, on_update: :cascade
    end
    add_foreign_key :trait_scores, :trait_descriptors, on_delete: :nullify, on_update: :cascade
  end
end