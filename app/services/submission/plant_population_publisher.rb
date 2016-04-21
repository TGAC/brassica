class Submission::PlantPopulationPublisher < Submission::Publisher

  private

  def associated_collections
    [plant_lines, plant_population_lists]
  end

  def plant_population
    raise ArgumentError, "Wrong submission type" unless submission.population?
    submission.submitted_object
  end

  def plant_lines
    plant_population.plant_lines.where(user_id: submission.user)
  end

  def plant_population_lists
    plant_population.plant_population_lists.where(user_id: submission.user)
  end
end
