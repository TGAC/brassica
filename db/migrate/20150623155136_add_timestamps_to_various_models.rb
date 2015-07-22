class AddTimestampsToVariousModels < ActiveRecord::Migration
  def up
    add_timestamps :plant_varieties
    add_timestamps :plant_scoring_units
    add_timestamps :plant_trials
    add_timestamps :plant_accessions
    add_timestamps :trait_descriptors
    add_timestamps :trait_scores

    safe_day = Time.now - 8.days

    PlantVariety.update_all(
      created_at: safe_day,
      updated_at: safe_day
    )
    PlantScoringUnit.update_all(
      created_at: safe_day,
      updated_at: safe_day
    )
    PlantTrial.update_all(
      created_at: safe_day,
      updated_at: safe_day
    )
    PlantAccession.update_all(
      created_at: safe_day,
      updated_at: safe_day
    )
    TraitDescriptor.update_all(
      created_at: safe_day,
      updated_at: safe_day
    )
    TraitScore.update_all(
      created_at: safe_day,
      updated_at: safe_day
    )
  end

  def down
    remove_timestamps :plant_varieties
    remove_timestamps :plant_scoring_units
    remove_timestamps :plant_trials
    remove_timestamps :plant_accessions
    remove_timestamps :trait_descriptors
    remove_timestamps :trait_scores
  end
end
