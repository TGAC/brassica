class DropAllDefaults < ActiveRecord::Migration
  def up
    change_column_default :countries, :country_code, nil

    change_column_default :design_factors, :design_factor_name, nil
    change_column_default :design_factors, :institute_id, nil
    change_column_default :design_factors, :trial_location_name, nil
    change_column_default :design_factors, :design_unit_counter, nil

    change_column_default :genotype_matrices, :matrix_compiled_by, nil
    change_column_default :genotype_matrices, :original_file_name, nil
    change_column_default :genotype_matrices, :number_markers_in_matrix, nil
    change_column_default :genotype_matrices, :number_lines_in_matrix, nil

    change_column_default :linkage_groups, :linkage_group_label, nil
    change_column_default :linkage_groups, :linkage_group_name, nil
    change_column_default :linkage_groups, :consensus_group_assignment, nil

    change_column_default :linkage_maps, :linkage_map_label, nil
    change_column_default :linkage_maps, :linkage_map_name, nil

    change_column_default :map_locus_hits, :consensus_group_assignment, nil
    change_column_default :map_locus_hits, :canonical_marker_name, nil
    change_column_default :map_locus_hits, :associated_sequence_id, nil
    change_column_default :map_locus_hits, :sequence_source_acronym, nil

    change_column_default :map_positions, :marker_assay_name, nil
    if column_exists?(:map_positions, :mapping_locus)
      change_column_default :map_positions, :mapping_locus, nil
    end

    change_column_default :marker_assays, :marker_assay_name, nil
    if column_exists?(:marker_assays, :canonical_marker_name)
      change_column_default :marker_assays, :canonical_marker_name, nil
    end

    change_column_default :marker_sequence_assignments, :marker_set, nil
    change_column_default :marker_sequence_assignments, :canonical_marker_name, nil

    change_column_default :plant_accessions, :plant_accession, nil

    change_column_default :plant_lines, :plant_line_name, nil

    change_column_default :plant_parts, :plant_part, nil

    change_column_default :plant_population_lists, :sort_order, nil

    change_column_default :plant_populations, :name, nil
    change_column_default :plant_populations, :canonical_population_name, nil

    change_column_default :plant_scoring_units, :scoring_unit_name, nil

    change_column_default :plant_trials, :plant_trial_name, nil
    change_column_default :plant_trials, :project_descriptor, nil

    change_column_default :pop_type_lookup, :population_type, nil
    change_column_default :pop_type_lookup, :population_class, nil

    change_column_default :population_loci, :mapping_locus, nil

    change_column_default :primers, :primer, nil
    change_column_default :primers, :sequence, nil
    change_column_default :primers, :sequence_id, nil
    change_column_default :primers, :sequence_source_acronym, nil

    change_column_default :probes, :probe_name, nil
    change_column_default :probes, :clone_name, nil
    change_column_default :probes, :sequence_id, nil
    change_column_default :probes, :sequence_source_acronym, nil

    change_column_default :processed_trait_datasets, :processed_trait_dataset_name, nil

    change_column_default :qtl, :qtl_rank, nil
    change_column_default :qtl, :map_qtl_label, nil
    change_column_default :qtl, :qtl_mid_position, nil
    change_column_default :qtl, :additive_effect, nil

    change_column_default :qtl_jobs, :qtl_job_name, nil
    change_column_default :qtl_jobs, :linkage_map_id, nil
    change_column_default :qtl_jobs, :qtl_software, nil
    change_column_default :qtl_jobs, :qtl_method, nil

    change_column_default :restriction_enzymes, :restriction_enzyme, nil
    change_column_default :restriction_enzymes, :recognition_site, nil

    change_column_default :trait_descriptors, :descriptor_name, nil
    change_column_default :trait_descriptors, :category, nil

    change_column_default :trait_grades, :trait_grade, nil
  end

  def down
    # Do nothing
  end
end
