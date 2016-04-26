class Submission::PlantTrialExporter < Submission::Exporter
  def documents
    {
      plant_trial: plant_trial,
      plant_scoring_units: plant_scoring_units,
      trait_scoring: trait_scoring
    }.reject { |_,v| v.nil? }
  end

  private

  def plant_trial
    generate_document PlantTrial,
                      { id: submitted_object.id }
  end

  def plant_scoring_units
    generate_document PlantScoringUnit,
                      { id: submitted_object.plant_scoring_units.pluck(:id) }
  end

  def trait_scoring
    @trait_descriptors = submitted_object.trait_descriptors
    data = submitted_object.scoring_table_data(@trait_descriptors.map(&:id), @submission.user.id)
    return nil if data.empty?
    CSV.generate(headers: true) do |csv|
      csv << ['Scoring unit name'] + @trait_descriptors.map(&:descriptor_name)
      data.each { |row| csv << row }
    end
  end
end
