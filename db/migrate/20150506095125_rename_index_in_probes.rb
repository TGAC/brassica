class RenameIndexInProbes < ActiveRecord::Migration
  def up
    execute("ALTER INDEX IF EXISTS probes_species_id_idx RENAME TO probes_taxonomy_term_id_idx")
  end

  def down
  end

end