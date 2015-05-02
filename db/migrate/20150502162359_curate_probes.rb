class CurateProbes < ActiveRecord::Migration
  require File.expand_path('lib/migration_helper')
  include MigrationHelper

  def up
    if column_exists?(:probes, :date_entered)
      execute("ALTER TABLE probes DROP COLUMN date_entered")
    end

    unless column_exists?(:probes, :taxonomy_term_id)
      add_column :probes, :taxonomy_term_id, :int
      upsert_index(:probes, :taxonomy_term_id)

      execute("UPDATE probes SET taxonomy_term_id = 48 WHERE species = 'rapa'")
      execute("UPDATE probes SET taxonomy_term_id = 27 WHERE species = 'napus'")
      execute("UPDATE probes SET taxonomy_term_id = 32 WHERE species = 'oleracea'")

      remove_column :probes, :species
    end
  end

  def down
  end
end