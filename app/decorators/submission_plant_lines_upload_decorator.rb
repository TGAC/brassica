class SubmissionPlantLinesUploadDecorator < SubmissionUploadDecorator
  def as_json(*)
    super.merge(uploaded_plant_lines: uploaded_plant_lines)
  end

  private

  def uploaded_plant_lines
    submission.content.step03.uploaded_plant_lines
  end
end
