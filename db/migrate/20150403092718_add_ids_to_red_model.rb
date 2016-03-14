class AddIdsToRedModel < ActiveRecord::Migration
  require File.expand_path('lib/migration_helper')
  include MigrationHelper

  def up

    #===============plant_trials=============#

    unless column_exists?(:plant_trials, :id)
      execute "ALTER TABLE plant_trials DROP CONSTRAINT IF EXISTS idx_143862_primary"
      execute "ALTER TABLE plant_trials DROP CONSTRAINT IF EXISTS plant_trials_pkey"
      if column_exists?(:plant_trials, :plant_trial_id)
        execute("ALTER TABLE plant_trials RENAME COLUMN plant_trial_id TO plant_trial_name")
      end
      add_column :plant_trials, :id, :primary_key
    else
      puts "Table plant_trials already contains column with name 'id'. Skipping."
    end

    # Replace FK in plant_scoring_units
    if column_exists?(:plant_scoring_units, :plant_trial_id) and
        PlantScoringUnit.column_for_attribute('plant_trial_id').type == :text
      puts "plant_trial_id FK in plant_scoring_units is of type text. Exchanging."
      execute("ALTER TABLE plant_scoring_units RENAME COLUMN plant_trial_id TO plant_trial_name")
      replace_fk('plant_scoring_units', 'plant_trials', 'plant_trial_name',
          'plant_trial_id', 'plant_trial_name')
    else
      puts "Table plant_scoring_units no longer contains a text-based FK for plant_trials. Skipping."
    end

    # Replace FK in processed_trait_datasets
    unless column_exists?(:processed_trait_datasets, :plant_trial_id)
      replace_fk('processed_trait_datasets', 'plant_trials', 'trial_id',
                 'plant_trial_id', 'plant_trial_name')
    else
      puts "Table processed_trait_datasets already contains a FK for plant_trials. Skipping."
    end

    #==============design_factors=============#

    unless column_exists?(:design_factors, :id)
      execute "ALTER TABLE design_factors DROP CONSTRAINT IF EXISTS idx_143500_primary"
      execute "ALTER TABLE design_factors DROP CONSTRAINT IF EXISTS design_factors_pkey"
      if column_exists?(:design_factors, :design_factor_id)
        execute("ALTER TABLE design_factors RENAME COLUMN design_factor_id TO design_factor_name")
      end
      add_column :design_factors, :id, :primary_key
    end

    # Replace FK in plant_scoring_units
    if column_exists?(:plant_scoring_units, :design_factor_id) and
        PlantScoringUnit.column_for_attribute('design_factor_id').type == :text
      puts "design_factor_id FK in plant_scoring_units is of type text. Exchanging."
      execute("ALTER TABLE plant_scoring_units RENAME COLUMN design_factor_id TO design_factor_name")
      replace_fk('plant_scoring_units', 'design_factors', 'design_factor_name',
                 'design_factor_id', 'design_factor_name')
    else
      puts "Table plant_scoring_units no longer contains a text-based FK for design_factors. Skipping."
    end

    #===============plant_parts===============#

    unless column_exists?(:plant_parts, :id)
      execute "ALTER TABLE plant_parts DROP CONSTRAINT IF EXISTS idx_143797_primary"
      add_column :plant_parts, :id, :primary_key
    end

    # Replace FK in plant_scoring_units
    unless column_exists?(:plant_scoring_units, :plant_part_id)
      replace_fk('plant_scoring_units', 'plant_parts', 'scored_plant_part',
                 'plant_part_id', 'plant_part')
    else
      puts "Table plant_scoring_units already contains a FK for plant_parts. Skipping."
    end

    #===============plant_scoring_units==============#

    unless column_exists?(:plant_scoring_units, :id)
      execute "ALTER TABLE plant_scoring_units DROP CONSTRAINT IF EXISTS idx_143842_primary"
      execute "ALTER TABLE plant_scoring_units DROP CONSTRAINT IF EXISTS plant_scoring_units_pkey"
      if column_exists?(:plant_scoring_units, :scoring_unit_id)
        execute("ALTER TABLE plant_scoring_units RENAME COLUMN scoring_unit_id TO scoring_unit_name")
      end
      add_column :plant_scoring_units, :id, :primary_key
    end

    # Replace FK in trait_scores
    if column_exists?(:trait_scores, :scoring_unit_id) and
        TraitScore.column_for_attribute('scoring_unit_id').type == :text
      puts "scoring_unit_id FK in trait_scores is of type text. Exchanging."
      execute("ALTER TABLE trait_scores RENAME COLUMN scoring_unit_id TO scoring_unit_name")
      replace_fk('trait_scores', 'plant_scoring_units', 'scoring_unit_name',
                 'plant_scoring_unit_id', 'scoring_unit_name')
    else
      puts "Table trait_scores no longer contains a text-based FK for plant_scoring_units. Skipping."
    end

    #================scoring_occasions==================#

    unless column_exists?(:scoring_occasions, :id)
      execute "ALTER TABLE scoring_occasions DROP CONSTRAINT IF EXISTS idx_144184_primary"
      execute "ALTER TABLE scoring_occasions DROP CONSTRAINT IF EXISTS scoring_occasions_pkey"
      if column_exists?(:scoring_occasions, :scoring_occasion_id)
        execute("ALTER TABLE scoring_occasions RENAME COLUMN scoring_occasion_id TO scoring_occasion_name")
      end
      add_column :scoring_occasions, :id, :primary_key
    end

    # Replace FK in trait_scores
    if column_exists?(:trait_scores, :scoring_occasion_id) and
        TraitScore.column_for_attribute('scoring_occasion_id').type == :text
      puts "scoring_occasion_id FK in trait_scores is of type text. Exchanging."
      execute("ALTER TABLE trait_scores RENAME COLUMN scoring_occasion_id TO scoring_occasion_name")
      replace_fk('trait_scores', 'scoring_occasions', 'scoring_occasion_name',
                 'scoring_occasion_id', 'scoring_occasion_name')
    else
      puts "Table trait_scores no longer contains a text-based FK for scoring_occasions. Skipping."
    end

    #=================trait_descriptors================#

    unless column_exists?(:trait_descriptors, :id)
      execute "ALTER TABLE trait_descriptors DROP CONSTRAINT IF EXISTS idx_144197_primary"
      execute "ALTER TABLE trait_descriptors DROP CONSTRAINT IF EXISTS trait_descriptors_pkey"
      if column_exists?(:trait_descriptors, :trait_descriptor_id)
        execute("ALTER TABLE trait_descriptors RENAME COLUMN trait_descriptor_id TO descriptor_label")
      end
      add_column :trait_descriptors, :id, :primary_key
    end

    # Replace FK in trait_grades
    if column_exists?(:trait_grades, :trait_descriptor_id) and
        TraitGrade.column_for_attribute('trait_descriptor_id').type == :text
      puts "trait_descriptor_id FK in trait_grades is of type text. Exchanging."
      execute("ALTER TABLE trait_grades RENAME COLUMN trait_descriptor_id TO descriptor_label")
      replace_fk('trait_grades', 'trait_descriptors', 'descriptor_label',
                 'trait_descriptor_id', 'descriptor_label')
    else
      puts "Table trait_grades no longer contains a text-based FK for trait_descriptors. Skipping."
    end

    # Replace FK in trait_scores
    if column_exists?(:trait_scores, :trait_descriptor_id) and
        TraitScore.column_for_attribute('trait_descriptor_id').type == :text
      puts "trait_descriptor_id FK in trait_scores is of type text. Exchanging."
      execute("ALTER TABLE trait_scores RENAME COLUMN trait_descriptor_id TO descriptor_label")
      replace_fk('trait_scores', 'trait_descriptors', 'descriptor_label',
                 'trait_descriptor_id', 'descriptor_label')
    else
      puts "Table trait_scores no longer contains a text-based FK for trait_descriptors. Skipping."
    end

    # Replace FK in processed_trait_datasets
    if column_exists?(:processed_trait_datasets, :trait_descriptor_id) and
        ProcessedTraitDataset.column_for_attribute('trait_descriptor_id').type == :text
      puts "trait_descriptor_id FK in processed_trait_datasets is of type text. Exchanging."
      execute("ALTER TABLE processed_trait_datasets RENAME COLUMN trait_descriptor_id TO descriptor_label")
      replace_fk('processed_trait_datasets', 'trait_descriptors', 'descriptor_label',
                 'trait_descriptor_id', 'descriptor_label')
    else
      puts "Table processed_trait_datasets no longer contains a text-based FK for trait_descriptors. Skipping."
    end

    #=====================trait_grades===================#
    unless column_exists?(:trait_grades, :id)
      execute "ALTER TABLE trait_grades DROP CONSTRAINT IF EXISTS trait_grades_pkey"
      add_column :trait_grades, :id, :primary_key
    end

    #=====================trait_scores===================#
    unless column_exists?(:trait_scores, :id)
      execute "ALTER TABLE trait_scores DROP CONSTRAINT IF EXISTS trait_scores_pkey"
      add_column :trait_scores, :id, :primary_key
    end

  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end

end