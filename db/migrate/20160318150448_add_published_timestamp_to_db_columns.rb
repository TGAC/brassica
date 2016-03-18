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

  @@dbtables_no_timestamps = [
    :design_factors,
    :genotype_matrices,
    :marker_sequence_assignments,
    :plant_parts,
    :processed_trait_datasets,
    :restriction_enzymes,
    :trait_grades
  ]

  def up

    @@dbtables_no_timestamps.each do |t|
      add_timestamps t
      execute("UPDATE #{t} SET created_at = '#{Date.today-8.days}'")
      execute("UPDATE #{t} SET updated_at = '#{Date.today-8.days}'")
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

    @@dbtables_no_timestamps.each do |t|
      remove_timestamps t
    end
  end
end
