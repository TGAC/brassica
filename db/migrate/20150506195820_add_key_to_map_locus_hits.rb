class AddKeyToMapLocusHits < ActiveRecord::Migration
  def up
    unless column_exists?(:map_locus_hits, :id)
      execute "ALTER TABLE map_locus_hits DROP CONSTRAINT IF EXISTS map_locus_hits_pkey"
      add_column :map_locus_hits, :id, :primary_key
    end
  end

  def down
  end
end