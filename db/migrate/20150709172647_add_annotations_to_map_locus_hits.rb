class AddAnnotationsToMapLocusHits < ActiveRecord::Migration
  def up
    add_column :map_locus_hits, :entered_by_whom, :string
    add_column :map_locus_hits, :date_entered, :date
    add_column :probes, :date_entered, :date
  end

  def down
    remove_column :map_locus_hits, :entered_by_whom
    remove_column :map_locus_hits, :date_entered
    remove_column :probes, :date_entered
  end
end
