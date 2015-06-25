class AddUserRelationsForeignKeyConstraints < ActiveRecord::Migration
  def change
    add_foreign_key :plant_accessions, :users, on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_lines, :users, on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_populations, :users, on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_population_lists, :users, on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_scoring_units, :users, on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_trials, :users, on_delete: :nullify, on_update: :cascade
    add_foreign_key :plant_varieties, :users, on_delete: :nullify, on_update: :cascade
    add_foreign_key :trait_descriptors, :users, on_delete: :nullify, on_update: :cascade
    add_foreign_key :trait_scores, :users, on_delete: :nullify, on_update: :cascade
  end
end
