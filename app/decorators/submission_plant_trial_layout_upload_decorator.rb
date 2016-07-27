class SubmissionPlantTrialLayoutUploadDecorator < SubmissionUploadDecorator
  def as_json(*)
    super.merge(
      original_file_url: file.url,
      small_file_url: file.url(:small)
    )
  end
end
