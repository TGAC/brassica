class AddIdsToGreenModel < ActiveRecord::Migration
  require File.expand_path('lib/migration_helper')
  include MigrationHelper

  def up

    #===============countries=============#

    unless column_exists?(:countries, :id)
      execute "ALTER TABLE countries DROP CONSTRAINT IF EXISTS idx_143365_primary"
      add_column :countries, :id, :primary_key
    else
      puts "Table countries already contains column with name 'id'. Skipping."
    end

    unless column_exists?(:plant_varieties, :id)
      execute "ALTER TABLE plant_varieties DROP CONSTRAINT IF EXISTS plant_varieties_pkey"
      add_column :plant_varieties, :id, :primary_key
    else
      puts "Table plant_varieties already contains column with name 'id'. Skipping."
    end

    # Extend coos with new FKs
    replace_fk('plant_variety_country_of_origin', 'countries', 'country_code',
               'country_id', 'country_code')
    replace_fk('plant_variety_country_of_origin', 'plant_varieties',
               'plant_variety_name', 'plant_variety_id', 'plant_variety_name')


    # Extend plant_trials with new FKs
    replace_fk('plant_trials', 'countries', 'country',
               'country_id', 'country_code')

    # Extend crs with new FKs
    replace_fk('plant_variety_country_registered', 'countries', 'country_code',
               'country_id', 'country_code')
    replace_fk('plant_variety_country_registered', 'plant_varieties',
               'plant_variety_name', 'plant_variety_id', 'plant_variety_name')

    #=========plant_lines==========#
    unless column_exists?(:plant_lines, :id)
      execute "ALTER TABLE plant_lines DROP CONSTRAINT IF EXISTS idx_143729_primary"
      add_column :plant_lines, :id, :primary_key
    end

    # Alter plant_accessions to use plant_line_id
    replace_fk('plant_accessions', 'plant_lines', 'plant_line_name',
               'plant_line_id', 'plant_line_name')

    # Alter plant_population_lists to use plant_line_id
    replace_fk('plant_population_lists', 'plant_lines', 'plant_line_name',
               'plant_line_id', 'plant_line_name')

    # Alter plant_populations to use male_parent_line_id and female_parent_line_id
    replace_fk('plant_populations', 'plant_lines', 'male_parent_line',
               'male_parent_line_id', 'plant_line_name')
    replace_fk('plant_populations', 'plant_lines', 'female_parent_line',
               'female_parent_line_id', 'plant_line_name')

    #=========plant_accessions=========#
    unless column_exists?(:plant_accessions, :id)
      execute "ALTER TABLE plant_accessions DROP CONSTRAINT IF EXISTS idx_143691_primary"
      add_column :plant_accessions, :id, :primary_key
    end

    # Alter plant_scoring_units to use plant_accession_id
    replace_fk('plant_scoring_units', 'plant_accessions', 'plant_accession',
               'plant_accession_id', 'plant_accession')

    #=========plant_populations========#

    # Existing PK is named plant_population_id - rename to 'name'
    unless column_exists?(:plant_populations, :name)
      execute("ALTER TABLE plant_populations DROP CONSTRAINT IF EXISTS idx_143808_primary")
      execute("ALTER TABLE plant_populations RENAME COLUMN plant_population_id TO name")
      add_column :plant_populations, :id, :primary_key
    end

    # Alter plant_population_lists to use new key in plant_populations
    unless column_exists?(:plant_population_lists, :plant_population_name)
      execute("ALTER TABLE plant_population_lists RENAME COLUMN plant_population_id TO plant_population_name")
      replace_fk('plant_population_lists', 'plant_populations', 'plant_population_name',
          'plant_population_id', 'name')
    end

    # Alter linkage_maps to make use of plant_population_id
    replace_fk('linkage_maps', 'plant_populations', 'mapping_population',
               'plant_population_id', 'name')

    # Alter population_loci to make use of plant_population_id
    replace_fk('population_loci', 'plant_populations', 'plant_population',
               'plant_population_id', 'name')

    # Alter processed_trait_datasets to make use of plant_population_id
    replace_fk('processed_trait_datasets', 'plant_populations', 'population_id',
               'plant_population_id', 'name')

    # Alter plant_trials to make use of plant_population_id
    replace_fk('plant_trials', 'plant_populations', 'plant_population',
               'plant_population_id', 'name')

    #=========population_type_lookup===========#
    unless column_exists?(:pop_type_lookup, :id)
      execute("ALTER TABLE pop_type_lookup DROP CONSTRAINT IF EXISTS idx_144008_primary")
      add_column :pop_type_lookup, :id, :primary_key
    end

    # Alter plant_populations to use population_type_id
    replace_fk('plant_populations', 'pop_type_lookup', 'population_type',
        'population_type_id', 'population_type')

  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end

end