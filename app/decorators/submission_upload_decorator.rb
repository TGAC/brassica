class SubmissionUploadDecorator < Draper::Decorator
  delegate_all

  def as_json(*)
    super.merge(
      delete_url: Rails.application.routes.url_helpers.
        submission_upload_path(object.submission, object),
      logs: object.logs,
      errors: object.errors[:file],
      summary: parser_summary
    )
  end

  def parser_summary
    [].tap do |summary|
      summary << 'Uploaded file parsing summary:'
      # TODO FIXME deliver better summary when parsed scores
      summary << object.submission.content.step03.trait_mapping.to_json
    end
  end
end
