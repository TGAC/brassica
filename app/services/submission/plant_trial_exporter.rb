class Submission::PlantTrialExporter < Submission::Exporter
  def documents
    {
      plant_trial: plant_trial,
      plant_scoring_units: plant_scoring_units,
      plant_accessions: plant_accessions,
      trait_descriptors: trait_descriptors,
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

  def plant_accessions
    generate_document PlantAccession,
                      { id: submitted_object.plant_scoring_units.pluck(:plant_accession_id) }
  end

  def trait_descriptors
    generate_document TraitDescriptor,
                      { id: submitted_object.trait_descriptors.map(&:id) }
  end

  def trait_scoring
    data = submitted_object.scoring_table_data(@submission.user.id)
    return nil if data.empty?
    CSV.generate(headers: true) do |csv|
      csv << ['Scoring unit name'] + submitted_object.decorate.trait_headers
      data.each { |row| csv << row[0...-1] }  # Drop the BIP internal id
    end
  end
end
