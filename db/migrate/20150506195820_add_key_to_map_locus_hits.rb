class AddKeyToMapLocusHits < ActiveRecord::Migration
  def up
    unless column_exists?(:map_locus_hits, :id)
      add_column :map_locus_hits, :id, :primary_key
    end
  end

  def down
  end
end