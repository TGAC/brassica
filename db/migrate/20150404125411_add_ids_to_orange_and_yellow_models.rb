class AddIdsToOrangeAndYellowModels < ActiveRecord::Migration
  require File.expand_path('lib/migration_helper')
  include MigrationHelper

  def up

    #===============processed_trait_datasets=============#

    unless column_exists?(:processed_trait_datasets, :id)
      execute "ALTER TABLE processed_trait_datasets DROP CONSTRAINT IF EXISTS idx_144089_primary"
      execute "ALTER TABLE processed_trait_datasets DROP CONSTRAINT IF EXISTS processed_trait_datasets_pkey"
      if column_exists?(:processed_trait_datasets, :processed_trait_dataset_id)
        execute("ALTER TABLE processed_trait_datasets RENAME COLUMN processed_trait_dataset_id \
          TO processed_trait_dataset_name")
      end
      add_column :processed_trait_datasets, :id, :primary_key
    else
      puts "Table processed_trait_datasets already contains column with name 'id'. Skipping."
    end

    # Replace FK in qtls
    if column_exists?(:qtl, :processed_trait_dataset_id) and
        Qtl.column_for_attribute('processed_trait_dataset_id').type == :text
      puts "processed_trait_dataset FK in qtl is of type text. Exchanging."
      execute("ALTER TABLE qtl RENAME COLUMN processed_trait_dataset_id TO processed_trait_dataset_name")
      replace_fk('qtl', 'processed_trait_datasets', 'processed_trait_dataset_name',
          'processed_trait_dataset_id', 'processed_trait_dataset_name')
    else
      puts "Table qtl no longer contains a text-based FK for processed_trait_datasets. Skipping."
    end

    #==============qtl_jobs=============#

    unless column_exists?(:qtl_jobs, :id)
      execute "ALTER TABLE qtl_jobs DROP CONSTRAINT IF EXISTS idx_144140_primary"
      execute "ALTER TABLE qtl_jobs DROP CONSTRAINT IF EXISTS qtl_jobs_pkey"
      if column_exists?(:qtl_jobs, :qtl_job_id)
        execute("ALTER TABLE qtl_jobs RENAME COLUMN qtl_job_id TO qtl_job_name")
      end
      add_column :qtl_jobs, :id, :primary_key
    else
      puts "Table qtl_jobs already contains column with name 'id'. Skipping."
    end

    # Replace FK in qtls
    if column_exists?(:qtl, :qtl_job_id) and
        Qtl.column_for_attribute('qtl_job_id').type == :text
      puts "qtl_job FK in qtl is of type text. Exchanging."
      execute("ALTER TABLE qtl RENAME COLUMN qtl_job_id TO qtl_job_name")
      replace_fk('qtl', 'qtl_jobs', 'qtl_job_name', 'qtl_job_id', 'qtl_job_name')
    else
      puts "Table qtl no longer contains a text-based FK for qtl_jobs. Skipping."
    end

    #==============qtl=============#

    unless column_exists?(:qtl, :id)
      execute "ALTER TABLE qtl DROP CONSTRAINT IF EXISTS qtl_pkey"
      add_column :qtl, :id, :primary_key
    else
      puts "Table qtl already contains column with name 'id'. Skipping."
    end

    #==============genotype_matrices============#

    unless column_exists?(:genotype_matrices, :id)
      execute "ALTER TABLE genotype_matrices DROP CONSTRAINT IF EXISTS idx_143519_primary"
      execute "ALTER TABLE genotype_matrices DROP CONSTRAINT IF EXISTS genotype_matrices_pkey"
      add_column :genotype_matrices, :id, :primary_key
    else
      puts "Table genotype_matrices already contains column with name 'id'. Skipping."
    end


    # Fix incorrectly named column in genotype_matrices
    if column_exists?(:genotype_matrices, :martix_complied_by)
      execute "ALTER TABLE genotype_matrices RENAME COLUMN martix_complied_by TO matrix_compiled_by"
    end

    #==============linkage_maps=============#

    unless column_exists?(:linkage_maps, :id)
      execute "ALTER TABLE linkage_maps DROP CONSTRAINT IF EXISTS idx_143550_primary"
      execute "ALTER TABLE linkage_maps DROP CONSTRAINT IF EXISTS linkage_maps_pkey"
      if column_exists?(:linkage_maps, :linkage_map_id)
        execute("ALTER TABLE linkage_maps RENAME COLUMN linkage_map_id TO linkage_map_label")
      end
      add_column :linkage_maps, :id, :primary_key
    else
      puts "Table linkage_maps already contains column with name 'id'. Skipping."
    end

    # Replace FK in map_linkage_group_lists
    if column_exists?(:map_linkage_group_lists, :linkage_map_id)
      puts "linkage_map FK in map_linkage_group_lists exists. Exchanging."
      execute("ALTER TABLE map_linkage_group_lists RENAME COLUMN linkage_map_id TO linkage_map_label")
      replace_fk('map_linkage_group_lists', 'linkage_maps', 'linkage_map_label',
                 'linkage_map_id', 'linkage_map_label')
    else
      puts "Table map_linkage_group_lists no longer contains a text-based FK for linkage_maps. Skipping."
    end

    # Replace FK in genotype_matrices
    if column_exists?(:genotype_matrices, :linkage_map_id) and
        GenotypeMatrix.column_for_attribute('linkage_map_id').type == :text
      puts "linkage_map FK in genotype_matrices is of type text. Exchanging."
      execute("ALTER TABLE genotype_matrices RENAME COLUMN linkage_map_id TO linkage_map_label")
      replace_fk('genotype_matrices', 'linkage_maps', 'linkage_map_label',
                 'linkage_map_id', 'linkage_map_label')
    else
      puts "Table genotype_matrices no longer contains a text-based FK for linkage_maps. Skipping."
    end

    # Replace FK in map_locus_hits
    if column_exists?(:map_locus_hits, :linkage_map_id) and
        MapLocusHit.column_for_attribute('linkage_map_id').type == :text
      puts "linkage_map FK in map_locus_hits is of type text. Exchanging."
      execute("ALTER TABLE map_locus_hits RENAME COLUMN linkage_map_id TO linkage_map_label")
      replace_fk('map_locus_hits', 'linkage_maps', 'linkage_map_label',
                 'linkage_map_id', 'linkage_map_label')
    else
      puts "Table map_locus_hits no longer contains a text-based FK for linkage_maps. Skipping."
    end

    #==============linkage_groups=============#

    unless column_exists?(:linkage_groups, :id)
      execute "ALTER TABLE linkage_groups DROP CONSTRAINT IF EXISTS idx_143534_primary"
      execute "ALTER TABLE linkage_groups DROP CONSTRAINT IF EXISTS linkage_groups_pkey"
      if column_exists?(:linkage_groups, :linkage_group_id)
        execute("ALTER TABLE linkage_groups RENAME COLUMN linkage_group_id TO linkage_group_label")
      end
      add_column :linkage_groups, :id, :primary_key
    else
      puts "Table linkage_groups already contains column with name 'id'. Skipping."
    end

    # Replace FK in map_linkage_group_lists
    if column_exists?(:map_linkage_group_lists, :linkage_group_id)
      puts "linkage_map FK in map_linkage_group_lists exists. Exchanging."
      execute("ALTER TABLE map_linkage_group_lists RENAME COLUMN linkage_group_id TO linkage_group_label")
      replace_fk('map_linkage_group_lists', 'linkage_groups', 'linkage_group_label',
                 'linkage_group_id', 'linkage_group_label')
    else
      puts "Table map_linkage_group_lists no longer contains a text-based FK for linkage_groups. Skipping."
    end

    # Replace FK in map_positions
    if column_exists?(:map_positions, :linkage_group_id) and
        MapPosition.column_for_attribute('linkage_group_id').type == :text
      puts "linkage_group FK in map_positions is of type text. Exchanging."
      execute("ALTER TABLE map_positions RENAME COLUMN linkage_group_id TO linkage_group_label")
      replace_fk('map_positions', 'linkage_groups', 'linkage_group_label',
                 'linkage_group_id', 'linkage_group_label')
    else
      puts "Table map_positions no longer contains a text-based FK for linkage_groups. Skipping."
    end

    # Replace FK in map_locus_hits
    if column_exists?(:map_locus_hits, :linkage_group_id) and
        MapLocusHit.column_for_attribute('linkage_group_id').type == :text
      puts "linkage_group FK in map_locus_hits is of type text. Exchanging."
      execute("ALTER TABLE map_locus_hits RENAME COLUMN linkage_group_id TO linkage_group_label")
      replace_fk('map_locus_hits', 'linkage_groups', 'linkage_group_label',
                 'linkage_group_id', 'linkage_group_label')
    else
      puts "Table map_locus_hits no longer contains a text-based FK for linkage_groups. Skipping."
    end

    # Replace FK in qtl
    if column_exists?(:qtl, :linkage_group_id) and
        Qtl.column_for_attribute('linkage_group_id').type == :text
      puts "linkage_group FK in qtl is of type text. Exchanging."
      execute("ALTER TABLE qtl RENAME COLUMN linkage_group_id TO linkage_group_label")
      replace_fk('qtl', 'linkage_groups', 'linkage_group_label',
                 'linkage_group_id', 'linkage_group_label')
    else
      puts "Table qtl no longer contains a text-based FK for linkage_groups. Skipping."
    end

    #==============population_loci=============#

    unless column_exists?(:population_loci, :id)
      execute "ALTER TABLE population_loci DROP CONSTRAINT IF EXISTS idx_143961_primary"
      execute "ALTER TABLE population_loci DROP CONSTRAINT IF EXISTS population_loci_pkey"
      add_column :population_loci, :id, :primary_key
    else
      puts "Table linkage_groups already contains column with name 'id'. Skipping."
    end

    # Replace FK in map_positions
    if column_exists?(:map_positions, :mapping_locus) and
        MapPosition.column_for_attribute('mapping_locus').type == :text
      puts "mapping_locus FK in map_positions is of type text. Exchanging."
      replace_fk('map_positions', 'population_loci', 'mapping_locus',
                 'population_locus_id', 'mapping_locus')
    else
      puts "Table map_positions no longer contains a text-based FK for population_loci. Skipping."
    end

    # Replace FK in map_locus_hits
    if column_exists?(:map_locus_hits, :mapping_locus) and
        MapLocusHit.column_for_attribute('mapping_locus').type == :text
      puts "mapping_locus FK in map_locus_hits is of type text. Exchanging."
      replace_fk('map_locus_hits', 'population_loci', 'mapping_locus',
                 'population_locus_id', 'mapping_locus')
    else
      puts "Table map_locus_hits no longer contains a text-based FK for population_loci. Skipping."
    end

    #==============map_positions=============#

    unless column_exists?(:map_positions, :id)
      execute "ALTER TABLE map_positions DROP CONSTRAINT IF EXISTS map_positions_pkey"
      add_column :map_positions, :id, :primary_key
    end

    # WIP pending decision on what to do about map_locus_hits -> map_positions
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end

end