class CreatePlantTrialTopologicalDescriptors < ActiveRecord::Migration
  def change
    create_table :plant_trial_topological_descriptors do |t|
      t.integer :environment_id, null: false
      t.references :topological_factor, null: false, foreign_key: true
      t.text :description, null: false
      t.timestamps null: false
    end

    add_foreign_key :plant_trial_topological_descriptors, :plant_trial_environments, column: :environment_id
    add_index :plant_trial_topological_descriptors, [:environment_id, :topological_factor_id], unique: true,
      name: :index_plant_trial_topological_descriptors
  end
end
