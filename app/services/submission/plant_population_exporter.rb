require 'csv'

class Submission::PlantPopulationExporter

  def initialize(submission)
    @submission = submission
  end

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

  def submitted_object
    raise ArgumentError, 'Wrong submission type' unless @submission.population?
    @submission.submitted_object
  end

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

  def generate_document(klass, query)
    data = klass.table_data(query: query).
                 map{ |r| r[0, klass.table_columns.size] }
    return nil if data.empty?
    CSV.generate(headers: true) do |csv|
      csv << humanize_columns(klass.table_columns)
      data.each { |row| csv << row }
    end
  end

  def humanize_columns(column_names)
    column_names.map do |column_name|
      column_name.split(/ as /i)[-1]
    end
  end
end
