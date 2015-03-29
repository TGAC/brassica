class DropDataStatus < ActiveRecord::Migration
  def up
    remove_column :design_factors, :data_status
    remove_column :genotype_matrices, :data_status
    remove_column :linkage_maps, :data_status
    remove_column :map_positions, :data_status
    remove_column :marker_assays, :data_status
    remove_column :marker_sequence_assignments, :data_status
    remove_column :plant_accessions, :data_status
    remove_column :plant_lines, :data_status
    remove_column :plant_parts, :data_status
    remove_column :plant_populations, :data_status
    remove_column :plant_population_lists, :data_status
    remove_column :plant_scoring_units, :data_status
    remove_column :plant_trials, :data_status
    remove_column :plant_varieties, :data_status
    remove_column :plant_variety_detail, :data_status
    remove_column :population_loci, :data_status
    remove_column :primers, :data_status
    remove_column :probes, :data_status
    remove_column :processed_trait_datasets, :data_status
    remove_column :qtl, :data_status
    remove_column :qtl_jobs, :data_status
    remove_column :scoring_occasions, :data_status
    remove_column :trait_descriptors, :data_status
    remove_column :trait_grades, :data_status
    remove_column :trait_scores, :data_status
  end

  def down
    add_column :design_factors, :data_status, :string, default: 'public'
    add_column :genotype_matrices, :data_status, :string, default: 'public'
    add_column :linkage_maps, :data_status, :string, default: 'public'
    add_column :map_positions, :data_status, :string, default: 'public'
    add_column :marker_assays, :data_status, :string, default: 'public'
    add_column :marker_sequence_assignments, :data_status, :string, default: 'public'
    add_column :plant_accessions, :data_status, :string, default: 'public'
    add_column :plant_lines, :data_status, :string, default: 'public'
    add_column :plant_parts, :data_status, :string, default: 'public'
    add_column :plant_populations, :data_status, :string, default: 'public'
    add_column :plant_population_lists, :data_status, :string, default: 'public'
    add_column :plant_scoring_units, :data_status, :string, default: 'public'
    add_column :plant_trials, :data_status, :string, default: 'public'
    add_column :plant_varieties, :data_status, :string, default: 'public'
    add_column :plant_variety_detail, :data_status, :string, default: 'public'
    add_column :population_loci, :data_status, :string, default: 'public'
    add_column :primers, :data_status, :string, default: 'public'
    add_column :probes, :data_status, :string, default: 'public'
    add_column :processed_trait_datasets, :data_status, :string, default: 'public'
    add_column :qtl, :data_status, :string, default: 'public'
    add_column :qtl_jobs, :data_status, :string, default: 'public'
    add_column :scoring_occasions, :data_status, :string, default: 'public'
    add_column :trait_descriptors, :data_status, :string, default: 'public'
    add_column :trait_grades, :data_status, :string, default: 'public'
    add_column :trait_scores, :data_status, :string, default: 'public'
  end
end