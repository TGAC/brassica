class SubmissionsController < ApplicationController

  before_filter :require_user

  def index
    @submissions = current_user.submissions
  end

  def show
    @submission = current_user.submissions.find(params[:id])
  end

  def edit
    @submission = current_user.submissions.find(params[:id])
  end

  def create
    submission = current_user.submissions.create!
    redirect_to edit_submission_path(submission)
  end

  def update
    submission = current_user.submissions.find(params[:id])

    if params[:back]
      submission.step_back
      redirect_to edit_submission_path(submission)
    else
      # TODO validate
      submission.data[submission.step] = params[:data]

      if submission.last_step?
        submission.finalize
        redirect_to submission_path(submission)
      else
        submission.step_forward
        redirect_to edit_submission_path(submission)
      end
    end
  end

  def destroy
    submission = current_user.submissions.find(params[:id])
    submission.destroy
    redirect_to submissions_path, notice: "Submission deleted"
  end
end
