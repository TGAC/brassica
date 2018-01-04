class CreatePlantTrialLamps < ActiveRecord::Migration
  def change
    create_table :plant_trial_lamps do |t|
      t.integer :environment_id, null: false
      t.references :lamp_type, null: false, foreign_key: true
      t.text :description
      t.timestamps null: false
    end

    add_foreign_key :plant_trial_lamps, :plant_trial_environments, column: :environment_id
  end
end
