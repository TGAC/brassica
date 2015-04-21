class RemoveImplicitNulls < ActiveRecord::Migration
  def up
    execute "ALTER TABLE qtl ALTER COLUMN map_qtl_label DROP NOT NULL"
    execute "UPDATE qtl SET map_qtl_label = NULL WHERE map_qtl_label = 'n/a'"

    execute "ALTER TABLE design_factors ALTER COLUMN design_factor_2 DROP NOT NULL"
    execute "UPDATE design_factors SET design_factor_2 = NULL WHERE design_factor_2 = 'na'"
    execute "ALTER TABLE design_factors ALTER COLUMN design_factor_2 DROP NOT NULL"
    execute "UPDATE design_factors SET design_factor_3 = NULL WHERE design_factor_3 = 'na'"
    execute "ALTER TABLE design_factors ALTER COLUMN design_factor_2 DROP NOT NULL"
    execute "UPDATE design_factors SET design_factor_4 = NULL WHERE design_factor_4 = 'na'"
    execute "ALTER TABLE design_factors ALTER COLUMN design_factor_2 DROP NOT NULL"
    execute "UPDATE design_factors SET design_factor_5 = NULL WHERE design_factor_5 = 'na'"

    execute "ALTER TABLE linkage_maps ALTER COLUMN map_version_no DROP NOT NULL"
    execute "ALTER TABLE linkage_maps ALTER COLUMN map_version_no DROP DEFAULT"
    execute "ALTER TABLE plant_accessions ALTER COLUMN year_produced DROP NOT NULL"
    execute "ALTER TABLE plant_accessions ALTER COLUMN year_produced DROP DEFAULT"
    execute "ALTER TABLE plant_trials ALTER COLUMN trial_year DROP NOT NULL"
    execute "ALTER TABLE plant_trials ALTER COLUMN trial_year DROP DEFAULT"
  end

  def down
  end
end