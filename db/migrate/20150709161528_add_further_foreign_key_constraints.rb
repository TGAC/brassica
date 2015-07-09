class AddFurtherForeignKeyConstraints < ActiveRecord::Migration
  def change
    add_foreign_key :map_positions, :marker_assays, on_delete: :nullify, on_update: :cascade

    add_foreign_key :qtl_jobs, :linkage_maps, on_delete: :nullify, on_update: :cascade
  end
end
