class DropNullConstraints < ActiveRecord::Migration
  def up
    execute "ALTER TABLE plant_varieties ALTER COLUMN data_attribution DROP NOT NULL"
    execute "ALTER TABLE plant_varieties ALTER COLUMN year_registered DROP NOT NULL"

    execute "ALTER TABLE plant_lines ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE plant_lines ALTER COLUMN entered_by_whom DROP NOT NULL"

    execute "ALTER TABLE plant_accessions ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE plant_accessions ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE plant_accessions ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE plant_accessions ALTER COLUMN data_owned_by DROP NOT NULL"

    execute "ALTER TABLE plant_population_lists ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE plant_population_lists ALTER COLUMN entered_by_whom DROP NOT NULL"

    execute "ALTER TABLE plant_populations ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE plant_populations ALTER COLUMN assigned_population_name DROP NOT NULL"

    execute "ALTER TABLE pop_type_lookup ALTER COLUMN assigned_by_whom DROP NOT NULL"

    execute "ALTER TABLE plant_trials ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE plant_trials ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE plant_trials ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE plant_trials ALTER COLUMN data_owned_by DROP NOT NULL"

    execute "ALTER TABLE design_factors ALTER COLUMN design_factor_1 DROP NOT NULL"
    execute "ALTER TABLE design_factors ALTER COLUMN design_factor_2 DROP NOT NULL"
    execute "ALTER TABLE design_factors ALTER COLUMN design_factor_3 DROP NOT NULL"
    execute "ALTER TABLE design_factors ALTER COLUMN design_factor_4 DROP NOT NULL"
    execute "ALTER TABLE design_factors ALTER COLUMN design_factor_5 DROP NOT NULL"
    execute "ALTER TABLE design_factors ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE design_factors ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE design_factors ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE design_factors ALTER COLUMN data_owned_by DROP NOT NULL"

    execute "ALTER TABLE plant_parts ALTER COLUMN description DROP NOT NULL"
    execute "ALTER TABLE plant_parts ALTER COLUMN described_by_whom DROP NOT NULL"
    execute "ALTER TABLE plant_parts ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE plant_parts ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE plant_parts ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE plant_parts ALTER COLUMN confirmed_by_whom DROP NOT NULL"

    execute "ALTER TABLE plant_scoring_units ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE plant_scoring_units ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE plant_scoring_units ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE plant_scoring_units ALTER COLUMN data_owned_by DROP NOT NULL"

    execute "ALTER TABLE trait_descriptors ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE trait_descriptors ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE trait_descriptors ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE trait_descriptors ALTER COLUMN data_owned_by DROP NOT NULL"

    execute "ALTER TABLE trait_grades ALTER COLUMN description DROP NOT NULL"
    execute "ALTER TABLE trait_grades ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE trait_grades ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE trait_grades ALTER COLUMN data_provenance DROP NOT NULL"

    execute "ALTER TABLE scoring_occasions ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE scoring_occasions ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE scoring_occasions ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE scoring_occasions ALTER COLUMN data_owned_by DROP NOT NULL"

    execute "ALTER TABLE trait_scores ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE trait_scores ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE trait_scores ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE trait_scores ALTER COLUMN data_owned_by DROP NOT NULL"

    execute "ALTER TABLE processed_trait_datasets ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE processed_trait_datasets ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE processed_trait_datasets ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE processed_trait_datasets ALTER COLUMN data_owned_by DROP NOT NULL"

    execute "ALTER TABLE qtl_jobs ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE qtl_jobs ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE qtl_jobs ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE qtl_jobs ALTER COLUMN data_owned_by DROP NOT NULL"

    execute "ALTER TABLE qtl ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE qtl ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE qtl ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE qtl ALTER COLUMN data_owned_by DROP NOT NULL"

    execute "ALTER TABLE linkage_groups ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE linkage_groups ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE linkage_groups ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE linkage_groups ALTER COLUMN data_owned_by DROP NOT NULL"
    execute "ALTER TABLE linkage_groups ALTER COLUMN data_status DROP NOT NULL"

    execute "ALTER TABLE linkage_maps ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE linkage_maps ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE linkage_maps ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE linkage_maps ALTER COLUMN data_owned_by DROP NOT NULL"

    execute "ALTER TABLE map_linkage_group_lists ALTER COLUMN comments DROP NOT NULL"

    execute "ALTER TABLE genotype_matrices ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE genotype_matrices ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE genotype_matrices ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE genotype_matrices ALTER COLUMN data_owned_by DROP NOT NULL"

    execute "ALTER TABLE population_loci ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE population_loci ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE population_loci ALTER COLUMN data_owned_by DROP NOT NULL"

    execute "ALTER TABLE map_positions ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE map_positions ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE map_positions ALTER COLUMN data_provenance DROP NOT NULL"
    execute "ALTER TABLE map_positions ALTER COLUMN data_owned_by DROP NOT NULL"

    execute "ALTER TABLE marker_sequence_assignments ALTER COLUMN entered_by_whom DROP NOT NULL"

    execute "ALTER TABLE primers ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE primers ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE primers ALTER COLUMN data_provenance DROP NOT NULL"

    execute "ALTER TABLE probes ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE probes ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE probes ALTER COLUMN data_provenance DROP NOT NULL"

    execute "ALTER TABLE marker_assays ALTER COLUMN comments DROP NOT NULL"
    execute "ALTER TABLE marker_assays ALTER COLUMN entered_by_whom DROP NOT NULL"
    execute "ALTER TABLE marker_assays ALTER COLUMN data_owned_by DROP NOT NULL"
  end

  def down
  end

end
