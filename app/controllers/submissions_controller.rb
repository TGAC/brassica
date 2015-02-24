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
    @content = step_content_form(@submission.step, @submission.content[@submission.step])
  end

  def create
    submission = current_user.submissions.create!
    redirect_to edit_submission_path(submission)
  end

  def update
    @submission = current_user.submissions.find(params[:id])

    if params[:back]
      @submission.step_back
      redirect_to edit_submission_path(@submission)
    else
      @content = step_content_form(@submission.step)

      if @content.valid?
        @content.save do |step_attrs|
          @submission.content = @submission.read_attribute(:content).merge(@submission.step.to_sym => step_attrs)
        end

        if @submission.last_step?
          @submission.finalize
          redirect_to submission_path(@submission)
        else
          @submission.step_forward
          redirect_to edit_submission_path(@submission)
        end
      else
        render action: :edit
      end
    end
  end

  def destroy
    submission = current_user.submissions.find(params[:id])
    submission.destroy
    redirect_to submissions_path, notice: "Submission deleted"
  end

  private

  def step_content_form(step, step_content_params = nil)
    klass_name = "Submissions::#{step.to_s.classify}ContentForm"
    klass = klass_name.constantize
    step_content_params ||= submission_content_params.permit(klass.permitted_properties)
    klass.new(OpenStruct.new(step_content_params || {}))
  end

  def submission_params
    params.require(:submission)
  end

  def submission_content_params
    submission_params.require(:content)
  end
end
