class Submission::PlantPopulationExporter < Submission::Exporter
  def documents
    {
      plant_population: plant_population,
      plant_lines: plant_lines,
      male_parent_line: male_parent_line,
      female_parent_line: female_parent_line,
      plant_varieties: plant_varieties
    }.reject { |_,v| v.nil? }
  end

  private

  def plant_population
    generate_document PlantPopulation,
                      { id: submitted_object.id }
  end

  def plant_lines
    generate_document PlantLine,
                      { id: submitted_object.plant_lines.pluck(:id) }
  end

  def plant_varieties
    plant_variety_ids = submitted_object.plant_lines.pluck(:plant_variety_id)
    plant_variety_ids << submitted_object.male_parent_line.try(:plant_variety_id)
    plant_variety_ids << submitted_object.female_parent_line.try(:plant_variety_id)
    generate_document PlantVariety,
                      { id: plant_variety_ids.compact }
  end

  def male_parent_line
    generate_document PlantLine,
                      { id: submitted_object.male_parent_line_id }
  end

  def female_parent_line
    generate_document PlantLine,
                      { id: submitted_object.female_parent_line_id }
  end
end
