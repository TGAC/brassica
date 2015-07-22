class AddFurtherUserRelationsForeignKeyConstraints < ActiveRecord::Migration
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
      add_foreign_key table_name, :users, on_delete: :nullify, on_update: :cascade
    end
  end
end
