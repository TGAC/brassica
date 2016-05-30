class SubmissionUploadDecorator < Draper::Decorator
  delegate_all

  def as_json(*)
    if new_record?
      super.merge(
        errors: formatted_errors
      )
    else
      super.merge(
        delete_url: delete_url,
        logs: object.logs
      )
    end
  end

  def delete_url
    Rails.application.routes.url_helpers.
      submission_upload_path(object.submission, object)
  end

  def formatted_errors
    errors = object.errors.dup
    # Remove duplicated paperclip validation messages
    errors[:file].reject! { |msg| errors[:file_content_type].include?(msg) }
    errors.full_messages
  end
end
