class Submission::PlantTrialPublisher < Submission::Publisher

  private

  def associated_collections
    [plant_scoring_units, plant_accessions, plant_lines, plant_varieties, trait_scores, trait_descriptors, design_factors]
  end

  def plant_trial
    raise ArgumentError, "Wrong submission type" unless submission.trial?
    submission.submitted_object
  end

  def plant_scoring_units
    plant_trial.plant_scoring_units.where(user_id: submission.user)
  end

  def plant_accessions
    PlantAccession.where(user_id: submission.user,
                         id: plant_scoring_units.pluck("DISTINCT plant_accession_id"))
  end

  def design_factors
    DesignFactor.where(user_id: submission.user,
                       id: plant_scoring_units.pluck("DISTINCT design_factor_id"))
  end

  def plant_lines
    PlantLine.where(user_id: submission.user,
                    id: plant_accessions.pluck("DISTINCT plant_line_id"))
  end

  def plant_varieties
    PlantVariety.where(user_id: submission.user,
                       id: plant_accessions.pluck("DISTINCT plant_variety_id"))
  end

  def trait_scores
    TraitScore.where(user_id: submission.user).of_trial(plant_trial.id)
  end

  def trait_descriptors
    TraitDescriptor.where(user_id: submission.user,
                          id: trait_scores.pluck("DISTINCT trait_descriptor_id"))
  end
end
