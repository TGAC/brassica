class AddIdsToOrangeAndYellowModels < ActiveRecord::Migration
  require File.expand_path('lib/migration_helper')
  include MigrationHelper

  def up

    #===============processed_trait_datasets=============#

    unless column_exists?(:processed_trait_datasets, :id)
      execute "ALTER TABLE processed_trait_datasets DROP CONSTRAINT IF EXISTS idx_144089_primary"
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
      add_column :qtl, :id, :primary_key
    else
      puts "Table qtl already contains column with name 'id'. Skipping."
    end

    #==============genotype_matrices============#

    unless column_exists?(:genotype_matrices, :id)
      execute "ALTER TABLE genotype_matrices DROP CONSTRAINT IF EXISTS idx_143519_primary"
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
      if column_exists?(:linkage_maps, :linkage_map_id)
        execute("ALTER TABLE linkage_maps RENAME COLUMN linkage_map_id TO linkage_map_label")
      end
      add_column :linkage_maps, :id, :primary_key
    else
      puts "Table linkage_maps already contains column with name 'id'. Skipping."
    end

    # Replace FK in map_linkage_group_lists
    if column_exists?(:map_linkage_group_lists, :linkage_map_id) and
        MapLinkageGroupList.column_for_attribute('linkage_map_id').type == :text
      puts "linkage_map FK in map_linkage_group_lists is of type text. Exchanging."
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
      if column_exists?(:linkage_groups, :linkage_group_id)
        execute("ALTER TABLE linkage_groups RENAME COLUMN linkage_group_id TO linkage_group_label")
      end
      add_column :linkage_groups, :id, :primary_key
    else
      puts "Table linkage_groups already contains column with name 'id'. Skipping."
    end

    # Replace FK in map_linkage_group_lists
    if column_exists?(:map_linkage_group_lists, :linkage_group_id) and
        MapLinkageGroupList.column_for_attribute('linkage_group_id').type == :text
      puts "linkage_map FK in map_linkage_group_lists is of type text. Exchanging."
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

    # WIP pending decision on what to do about map_locus_hits -> map_positions


    #
    # unless column_exists?(:design_factors, :id)
    #   execute "ALTER TABLE design_factors DROP CONSTRAINT IF EXISTS idx_143500_primary"
    #   if column_exists?(:design_factors, :design_factor_id)
    #     execute("ALTER TABLE design_factors RENAME COLUMN design_factor_id TO design_factor_name")
    #   end
    #   add_column :design_factors, :id, :primary_key
    # end
    #
    # # Replace FK in plant_scoring_units
    # if column_exists?(:plant_scoring_units, :design_factor_id) and
    #     PlantScoringUnit.column_for_attribute('design_factor_id').type == :text
    #   puts "design_factor_id FK in plant_scoring_units is of type text. Exchanging."
    #   execute("ALTER TABLE plant_scoring_units RENAME COLUMN design_factor_id TO design_factor_name")
    #   replace_fk('plant_scoring_units', 'design_factors', 'design_factor_name',
    #              'design_factor_id', 'design_factor_name')
    # else
    #   puts "Table plant_scoring_units no longer contains a text-based FK for design_factors. Skipping."
    # end
    #
    # #===============plant_parts===============#
    #
    # unless column_exists?(:plant_parts, :id)
    #   execute "ALTER TABLE plant_parts DROP CONSTRAINT IF EXISTS idx_143797_primary"
    #   add_column :plant_parts, :id, :primary_key
    # end
    #
    # # Replace FK in plant_scoring_units
    # unless column_exists?(:plant_scoring_units, :plant_part_id)
    #   replace_fk('plant_scoring_units', 'plant_parts', 'scored_plant_part',
    #              'plant_part_id', 'plant_part')
    # else
    #   puts "Table plant_scoring_units already contains a FK for plant_parts. Skipping."
    # end
    #
    # #===============plant_scoring_units==============#
    #
    # unless column_exists?(:plant_scoring_units, :id)
    #   execute "ALTER TABLE plant_scoring_units DROP CONSTRAINT IF EXISTS idx_143842_primary"
    #   if column_exists?(:plant_scoring_units, :scoring_unit_id)
    #     execute("ALTER TABLE plant_scoring_units RENAME COLUMN scoring_unit_id TO scoring_unit_name")
    #   end
    #   add_column :plant_scoring_units, :id, :primary_key
    # end
    #
    # # Replace FK in trait_scores
    # if column_exists?(:trait_scores, :scoring_unit_id) and
    #     TraitScore.column_for_attribute('scoring_unit_id').type == :text
    #   puts "scoring_unit_id FK in trait_scores is of type text. Exchanging."
    #   execute("ALTER TABLE trait_scores RENAME COLUMN scoring_unit_id TO scoring_unit_name")
    #   replace_fk('trait_scores', 'plant_scoring_units', 'scoring_unit_name',
    #              'plant_scoring_unit_id', 'scoring_unit_name')
    # else
    #   puts "Table trait_scores no longer contains a text-based FK for plant_scoring_units. Skipping."
    # end
    #
    # #================scoring_occasions==================#
    #
    # unless column_exists?(:scoring_occasions, :id)
    #   execute "ALTER TABLE scoring_occasions DROP CONSTRAINT IF EXISTS idx_144184_primary"
    #   if column_exists?(:scoring_occasions, :scoring_occasion_id)
    #     execute("ALTER TABLE scoring_occasions RENAME COLUMN scoring_occasion_id TO scoring_occasion_name")
    #   end
    #   add_column :scoring_occasions, :id, :primary_key
    # end
    #
    # # Replace FK in trait_scores
    # if column_exists?(:trait_scores, :scoring_occasion_id) and
    #     TraitScore.column_for_attribute('scoring_occasion_id').type == :text
    #   puts "scoring_occasion_id FK in trait_scores is of type text. Exchanging."
    #   execute("ALTER TABLE trait_scores RENAME COLUMN scoring_occasion_id TO scoring_occasion_name")
    #   replace_fk('trait_scores', 'scoring_occasions', 'scoring_occasion_name',
    #              'scoring_occasion_id', 'scoring_occasion_name')
    # else
    #   puts "Table trait_scores no longer contains a text-based FK for scoring_occasions. Skipping."
    # end
    #
    # #=================trait_descriptors================#
    #
    # unless column_exists?(:trait_descriptors, :id)
    #   execute "ALTER TABLE trait_descriptors DROP CONSTRAINT IF EXISTS idx_144197_primary"
    #   if column_exists?(:trait_descriptors, :trait_descriptor_id)
    #     execute("ALTER TABLE trait_descriptors RENAME COLUMN trait_descriptor_id TO descriptor_label")
    #   end
    #   add_column :trait_descriptors, :id, :primary_key
    # end
    #
    # # Replace FK in trait_grades
    # if column_exists?(:trait_grades, :trait_descriptor_id) and
    #     TraitGrade.column_for_attribute('trait_descriptor_id').type == :text
    #   puts "trait_descriptor_id FK in trait_grades is of type text. Exchanging."
    #   execute("ALTER TABLE trait_grades RENAME COLUMN trait_descriptor_id TO descriptor_label")
    #   replace_fk('trait_grades', 'trait_descriptors', 'descriptor_label',
    #              'trait_descriptor_id', 'descriptor_label')
    # else
    #   puts "Table trait_grades no longer contains a text-based FK for trait_descriptors. Skipping."
    # end
    #
    # # Replace FK in trait_scores
    # if column_exists?(:trait_scores, :trait_descriptor_id) and
    #     TraitScore.column_for_attribute('trait_descriptor_id').type == :text
    #   puts "trait_descriptor_id FK in trait_scores is of type text. Exchanging."
    #   execute("ALTER TABLE trait_scores RENAME COLUMN trait_descriptor_id TO descriptor_label")
    #   replace_fk('trait_scores', 'trait_descriptors', 'descriptor_label',
    #              'trait_descriptor_id', 'descriptor_label')
    # else
    #   puts "Table trait_scores no longer contains a text-based FK for trait_descriptors. Skipping."
    # end
    #
    # # Replace FK in processed_trait_datasets
    # if column_exists?(:processed_trait_datasets, :trait_descriptor_id) and
    #     ProcessedTraitDataset.column_for_attribute('trait_descriptor_id').type == :text
    #   puts "trait_descriptor_id FK in processed_trait_datasets is of type text. Exchanging."
    #   execute("ALTER TABLE processed_trait_datasets RENAME COLUMN trait_descriptor_id TO descriptor_label")
    #   replace_fk('processed_trait_datasets', 'trait_descriptors', 'descriptor_label',
    #              'trait_descriptor_id', 'descriptor_label')
    # else
    #   puts "Table processed_trait_datasets no longer contains a text-based FK for trait_descriptors. Skipping."
    # end
    #
    # #=====================trait_grades===================#
    # unless column_exists?(:trait_grades, :id)
    #   add_column :trait_grades, :id, :primary_key
    # end
    #
    # #=====================trait_scores===================#
    # unless column_exists?(:trait_scores, :id)
    #   add_column :trait_scores, :id, :primary_key
    # end

  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end

end