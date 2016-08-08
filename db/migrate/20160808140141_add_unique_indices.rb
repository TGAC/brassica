class AddUniqueIndices < ActiveRecord::Migration
  @@unique_attrs = [
    [:countries, :country_code],
    [:linkage_groups, :linkage_group_label],
    [:linkage_maps, :linkage_map_label],
    [:marker_assays, :marker_assay_name],
    [:plant_lines, :plant_line_name],
    [:plant_parts, :plant_part],
    [:plant_populations, :name],
    [:plant_trials, :plant_trial_name],
    [:plant_varieties, :plant_variety_name],
    [:primers, :primer],
    [:probes, :probe_name],
    [:processed_trait_datasets, :processed_trait_dataset_name],
    [:qtl_jobs, :qtl_job_name],
    [:restriction_enzymes, :restriction_enzyme],
    [:taxonomy_terms, :name],
    [:traits, :name]
  ]

  def up
    @@unique_attrs.each do |attr|
      table_name = attr[0].to_s
      column_name = attr[1].to_s

      idx_name = "#{table_name}_#{column_name}_idx"

      # Drop existing index (if present)
      execute("DROP INDEX IF EXISTS #{idx_name}")

      execute("CREATE UNIQUE INDEX #{table_name}_#{column_name}_idx ON #{table_name} (#{column_name})")
      puts "...successfully added index on column #{column_name} in #{table_name}."
    end

    # Special case for plant_accessions
    # Recreate regular (nonunique) index on plant_accessions.plant_accession
    execute("DROP INDEX IF EXISTS plant_accessions_plant_accession_idx")
    execute("CREATE INDEX plant_accessions_plant_accession_idx ON plant_accessions (plant_accession)")
    # Create a joint unique index on plant_accessions.plant_accession and plant_accessions.originating_organisation
    execute("DROP INDEX IF EXISTS plant_accessions_pa_oo_idx")
    execute("DROP INDEX IF EXISTS plant_accessions_plant_accession_originating_organisation_idx")
    execute("CREATE UNIQUE INDEX plant_accessions_plant_accession_originating_organisation_idx ON plant_accessions (plant_accession, originating_organisation)")
  end

  def down
  end
end
