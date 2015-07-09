class RelateOtherModelsToUser < ActiveRecord::Migration
  def change
    [
      :linkage_groups,
      :linkage_maps,
      :map_locus_hits,
      :map_positions,
      :marker_assays,
      :population_loci,
      :primers,
      :probes,
      :qtl,
      :qtl_jobs
    ].each do |table_name|
      change_table table_name do |t|
        t.references :user
      end
    end
  end
end
