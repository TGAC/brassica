class AddIdsToBlueModels < ActiveRecord::Migration
  require File.expand_path('lib/migration_helper')
  include MigrationHelper

  def up

    #===============marker_sequence_assignments=============#

    unless column_exists?(:marker_sequence_assignments, :id)
      execute "ALTER TABLE marker_sequence_assignments DROP CONSTRAINT IF EXISTS idx_143632_primary"
      add_column :marker_sequence_assignments, :id, :primary_key
    else
      puts "Table marker_sequence_assignments already contains column with name 'id'. Skipping."
    end

    # Replace FK in marker_assays
    unless column_exists?(:marker_assays, :marker_sequence_assignment_id)
      replace_fk('marker_assays', 'marker_sequence_assignments', 'canonical_marker_name',
          'marker_sequence_assignment_id', 'canonical_marker_name')
    else
      puts "Table marker_assays already contains a numerical FK for marker_sequence_assignments. Skipping."
    end

    #==============restriction_enzymes=============#

    unless column_exists?(:restriction_enzymes, :id)
      execute "ALTER TABLE restriction_enzymes DROP CONSTRAINT IF EXISTS idx_144160_primary"
      add_column :restriction_enzymes, :id, :primary_key
    else
      puts "Table restriction_enzymes already contains column with name 'id'. Skipping."
    end

    # Restore FKs in marker_assays
    unless column_exists?(:marker_assays, :restriction_enzyme_a_id)
      execute "ALTER TABLE marker_assays ADD COLUMN restriction_enzyme_a_id INT"
    end
    unless column_exists?(:marker_assays, :restriction_enzyme_b_id)
      execute "ALTER TABLE marker_assays ADD COLUMN restriction_enzyme_b_id INT"
    end

    #==============primers=============#

    unless column_exists?(:primers, :id)
      execute "ALTER TABLE primers DROP CONSTRAINT IF EXISTS idx_144017_primary"
      add_column :primers, :id, :primary_key
    else
      puts "Table primersalready contains column with name 'id'. Skipping."
    end

    # Replace FKs in marker_assays
    unless column_exists?(:marker_assays, :primer_a_id)
      unless column_exists?(:marker_assays, :primer_a_name)
        execute "ALTER TABLE marker_assays RENAME COLUMN primer_a TO primer_a_name"
      end
      replace_fk('marker_assays', 'primers', 'primer_a_name', 'primer_a_id', 'primer')
    else
      puts "Table marker_assays already contains a numerical FK for primers (A). Skipping."
    end
    unless column_exists?(:marker_assays, :primer_b_id)
      unless column_exists?(:marker_assays, :primer_b_name)
        execute "ALTER TABLE marker_assays RENAME COLUMN primer_b TO primer_b_name"
      end
      replace_fk('marker_assays', 'primers', 'primer_b_name', 'primer_b_id', 'primer')
    else
      puts "Table marker_assays already contains a numerical FK for primers (B). Skipping."
    end

    #==============probes============#

    unless column_exists?(:probes, :id)
      execute "ALTER TABLE probes DROP CONSTRAINT IF EXISTS idx_144041_primary"
      add_column :probes, :id, :primary_key
    else
      puts "Table probes already contains column with name 'id'. Skipping."
    end

    # Replace FK in marker_assays
    unless column_exists?(:marker_assays, :probe_id)
      replace_fk('marker_assays', 'probes', 'probe_name', 'probe_id', 'probe_name')
    else
      puts "Table marker_assays already contains a numerical FK for probes. Skipping."
    end

    #==============marker_assays=============#

    unless column_exists?(:marker_assays, :id)
      execute "ALTER TABLE marker_assays DROP CONSTRAINT IF EXISTS idx_143611_primary"
      add_column :marker_assays, :id, :primary_key
    else
      puts "Table marker_assays already contains column with name 'id'. Skipping."
    end

    # Replace FK in population_loci
    unless column_exists?(:population_loci, :marker_assay_id)
      replace_fk('population_loci', 'marker_assays', 'marker_assay_name',
                 'marker_assay_id', 'marker_assay_name')
    else
      puts "Table population_loci no longer contains a text-based FK for marker_assays. Skipping."
    end
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end

end