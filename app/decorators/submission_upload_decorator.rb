class SubmissionUploadDecorator < Draper::Decorator
  delegate_all

  def as_json(*)
    super.merge(
      delete_url: Rails.application.routes.url_helpers.
        submission_upload_path(object.submission, object)
    )
  end
end
