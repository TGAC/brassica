class AddPublishedFlagToDbColumns < ActiveRecord::Migration
  @@dbtables = [
    :design_factors,
    :genotype_matrices,
    :linkage_groups,
    :linkage_maps,
    :map_locus_hits,
    :map_positions,
    :marker_assays,
    :marker_sequence_assignments,
    :plant_accessions,
    :plant_lines,
    :plant_parts,
    :plant_population_lists,
    :plant_populations,
    :plant_scoring_units,
    :plant_trials,
    :plant_varieties,
    :pop_type_lookup,
    :population_loci,
    :primers,
    :probes,
    :processed_trait_datasets,
    :qtl,
    :qtl_jobs,
    :restriction_enzymes,
    :submission_uploads,
    :submissions,
    :taxonomy_terms,
    :trait_descriptors,
    :trait_grades,
    :trait_scores
  ]

  def up
    @@dbtables.each do |table|
      unless column_exists?(table, :published)
        add_column(table, :published, :boolean, null: false, default:true)
      end
    end
  end

  def down
  end
end
