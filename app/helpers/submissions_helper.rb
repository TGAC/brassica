module SubmissionsHelper
  def create_submission_button
    link_to "Submit new data", new_submission_path, class: 'btn btn-primary'
  end

  def submission_link(submission)
    link_to submission_label(submission), submission_path(submission), class: 'show-submission'
  end

  def submission_label(submission)
    PlantPopulationSubmissionDecorator.decorate(submission).label
  end
end
