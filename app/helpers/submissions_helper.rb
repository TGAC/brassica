module SubmissionsHelper
  def new_submission_button
    link_to "Submit new data", new_submission_path, class: 'btn btn-primary'
  end

  def my_submissions_button
    link_to "Back to submissions list", submissions_path, class: 'btn btn-primary'
  end

  def new_deposition_button
    link_to 'Deposit in Zenodo.org',
            new_deposition_path(deposition: { submission_id: @submission.id }),
            class: 'btn btn-primary',
            title: 'Deposit this submission content in Zenodo.org to get official dataset DOI number.'
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

  def submission_value(submission, attr, label = nil)
    value = decorator(submission).send(attr)
    label ||= attr.to_s.humanize

    render partial: "submissions/show/value",
           locals: { value: value, label: label }
  end

  def submission_form(submission, &block)
    options = {
      builder: Submissions::FormBuilder,
      html: { class: "edit-submission" }
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

  private

  def decorator(submission)
    return submission if submission.is_a?(SubmissionDecorator)

    case submission.submission_type
    when 'population'
      PlantPopulationSubmissionDecorator.decorate(submission)
    when 'trial'
      PlantTrialSubmissionDecorator.decorate(submission)
    else
      raise ArgumentError, "Unknown submission type: #{submission.submission_type}"
    end
  end
end
