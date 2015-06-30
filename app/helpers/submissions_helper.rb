module SubmissionsHelper
  def new_submission_button
    link_to "Submit new data", new_submission_path, class: 'btn btn-primary'
  end

  def my_submissions_button
    link_to "My submissions", submissions_path, class: 'btn btn-primary'
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

  private

  def decorator(submission)
    case submission.submission_type
    when 'population'
      PlantPopulationSubmissionDecorator.decorate(submission)
    when 'trial'
      PlantTrialSubmissionDecorator.decorate(submission)
    else
      nil
    end
  end
end
