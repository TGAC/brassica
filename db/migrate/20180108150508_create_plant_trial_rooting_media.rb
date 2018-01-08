class CreatePlantTrialRootingMedia < ActiveRecord::Migration
  def change
    create_table :plant_trial_rooting_media do |t|
      t.integer :environment_id, null: false
      t.integer :medium_type_id, null: false
      t.text :description

      t.timestamps null: false
    end

    add_foreign_key :plant_trial_rooting_media, :plant_trial_environments, column: :environment_id
    add_foreign_key :plant_trial_rooting_media, :plant_treatment_types, column: :medium_type_id

    add_index :plant_trial_rooting_media, [:environment_id, :medium_type_id],
      name: "idx_plant_trial_rooting_media"
  end
end
