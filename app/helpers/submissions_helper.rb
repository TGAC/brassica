module SubmissionsHelper
  def new_submission_button
    link_to "Submit new data", new_submission_path, class: 'btn btn-primary'
  end

  def my_submissions_button
    link_to "Back to submissions list", submissions_path, class: 'btn btn-default'
  end

  def submission_private_link(submission)
    link_to submission_label(submission), submission_path(submission)
  end

  def submission_public_link(submission)
    link_to(
      submission_label(submission),
      submission_details_path(submission)
    )
  end

  def submission_details_path(submission)
    decorator(submission).details_path
  end

  def submission_label(submission)
    decorator(submission).label
  end

  def submission_type(submission)
    decorator(submission).submission_type
  end

  def submission_details(submission)
    decorator(submission).further_details.html_safe
  end

  def submission_value(submission, attr, label = nil, url = nil)
    value = decorator(submission).send(attr)
    value = value.join(", ") if value.is_a?(Array)
    label ||= attr.to_s.humanize
    url = nil unless submission.finalized?

    render partial: "submissions/show/value",
           locals: { value: value, label: label, url: url }
  end

  def submission_form(submission, &block)
    submission = submission.object if submission.is_a?(Draper::Decorator)
    options = {
      builder: Submissions::FormBuilder,
      html: {
        class: "edit-submission",
        data: { "step": submission.step_no }
      }
    }

    form_for(submission, options, &block)
  end

  # Turns a collection of model objects (AR or otherwise) into options HTML
  def options_for_submission_select(collection, text_attr, options = {})
    collection = Array(collection)

    if collection.map(&:class).uniq.size > 1
      raise ArgumentError, "Mixed-type collection not supported"
    end

    return '' unless collection.present?

    id_attr = options[:id] == false ? text_attr : :id
    selected = collection.map(&id_attr)

    options_from_collection_for_select(collection, id_attr, text_attr, selected)
  end

  def delete_submission_upload_button(upload, options = {})
    if upload
      url = submission_upload_path(upload.submission, upload.id)
    else
      url = ''
    end

    options = options.merge(remote: true, method: :delete)

    link_to "Delete", url, options
  end

  def submission_template_link(path)
    link_to path, class: 'btn btn-success' do
      content_tag(:i, nil, class: %w(fa fa-download)) +
        content_tag(:span, "Download template")
    end
  end

  private

  def decorator(submission)
    SubmissionDecorator.decorate!(submission)
  end
end
