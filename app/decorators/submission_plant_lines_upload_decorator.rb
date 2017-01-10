class SubmissionPlantLinesUploadDecorator < SubmissionUploadDecorator
  def as_json(*)
    super.merge(new_plant_lines: new_plant_lines)
  end

  private

  def new_plant_lines
    submission.content.step03.new_plant_lines
  end
end
