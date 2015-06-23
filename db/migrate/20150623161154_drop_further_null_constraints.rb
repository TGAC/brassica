class DropFurtherNullConstraints < ActiveRecord::Migration
  def up
    execute "ALTER TABLE plant_trials ALTER COLUMN plant_trial_description DROP NOT NULL"
    execute "ALTER TABLE plant_trials ALTER COLUMN institute_id DROP NOT NULL"
    execute "ALTER TABLE plant_trials ALTER COLUMN institute_id DROP DEFAULT"
    execute "ALTER TABLE plant_trials ALTER COLUMN trial_location_site_name DROP NOT NULL"
    execute "ALTER TABLE plant_trials ALTER COLUMN trial_location_site_name DROP DEFAULT"
    execute "ALTER TABLE plant_trials ALTER COLUMN place_name DROP NOT NULL"
    execute "ALTER TABLE plant_trials ALTER COLUMN place_name DROP DEFAULT"
    execute "ALTER TABLE plant_trials ALTER COLUMN latitude DROP NOT NULL"
    execute "ALTER TABLE plant_trials ALTER COLUMN latitude DROP DEFAULT"
    execute "ALTER TABLE plant_trials ALTER COLUMN longitude DROP NOT NULL"
    execute "ALTER TABLE plant_trials ALTER COLUMN longitude DROP DEFAULT"
    execute "ALTER TABLE plant_trials ALTER COLUMN contact_person DROP NOT NULL"
    execute "ALTER TABLE plant_trials ALTER COLUMN contact_person DROP DEFAULT"

    execute "ALTER TABLE trait_descriptors ALTER COLUMN where_to_score DROP NOT NULL"
    execute "ALTER TABLE trait_descriptors ALTER COLUMN descriptor_label DROP NOT NULL"
    execute "ALTER TABLE trait_descriptors ALTER COLUMN descriptor_label DROP DEFAULT"
  end

  def down
  end
end
