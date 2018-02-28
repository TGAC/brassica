class SubmissionPlantLinesUploadDecorator < SubmissionUploadDecorator
  def as_json(*)
    super.merge(uploaded_existing_plant_lines: uploaded_existing_plant_lines,
                uploaded_new_plant_lines: uploaded_new_plant_lines)
  end

  private

  def uploaded_plant_lines
    submission.content.uploaded_plant_lines || []
  end

  def new_plant_lines
    submission.content.new_plant_lines || []
  end

  def uploaded_existing_plant_lines
    PlantLine.
      visible(submission.user_id).
      where(plant_line_name: uploaded_plant_lines).
      pluck(:id, :plant_line_name).
      map { |id, plant_line_name| { id: id, plant_line_name: plant_line_name } }
  end

  def uploaded_new_plant_lines
    new_plant_lines.select do |plant_line_attrs|
      uploaded_plant_lines.include?(plant_line_attrs.fetch("plant_line_name"))
    end
  end
end
