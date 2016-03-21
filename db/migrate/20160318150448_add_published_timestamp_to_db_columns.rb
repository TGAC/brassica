class AddPublishedTimestampToDbColumns < ActiveRecord::Migration
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
    :taxonomy_terms,
    :trait_descriptors,
    :trait_grades,
    :trait_scores
  ]

  def up
    # Fix error in previous migration
    if column_exists?(:plant_variety_country_registered, :published)
      remove_column(:plant_variety_country_registered, :published)
    end
    if column_exists?(:plant_variety_country_of_origin, :published)
      remove_column(:plant_variety_country_of_origin, :published)
    end

    @@dbtables.each do |table|
      unless column_exists?(table, :published_on)
        add_column(table, :published_on, :datetime, null: true)
        execute("UPDATE #{table} SET published_on = updated_at")
      end
      # Add CHECK constraint
      execute("ALTER TABLE #{table.to_s} ADD CONSTRAINT #{table.to_s}_pub_chk CHECK (published = FALSE OR published_on IS NOT NULL)")
    end
  end

  def down
    @@dbtables.each do |table|
      if column_exists?(table, :published_on)
        # Drop CHECK constraint
        execute("ALTER TABLE #{table.to_s} DROP CONSTRAINT IF EXISTS #{table.to_s}_pub_chk")
        remove_column(table, :published_on)
      end
    end
  end
end
