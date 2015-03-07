module SubmissionsHelper
  def create_submission_button
    button_to "Submit new population", submissions_path, class: 'btn btn-primary', method: 'post'
  end

  def submission_link(submission)
    link_to submission_label(submission), submission_path(submission), class: 'show-submission'
  end

  def submission_label(submission)
    PlantPopulationSubmissionDecorator.decorate(submission).label
  end
end
