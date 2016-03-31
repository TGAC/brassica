class Submissions::UploadsController < ApplicationController

  prepend_before_filter :authenticate_user!
  before_filter :require_submission_owner

  def new
    @traits = PlantTrialSubmissionDecorator.decorate(submission).sorted_trait_names
    data = render_to_string template: 'submissions/steps/trial/plant_trial_scoring_data.tsv',
                            layout: false
    send_data data,
              content_type: 'text/tsv; charset=UTF-8; header=present',
              disposition: 'attachment; filename=plant_trial_scoring_data.tsv'
  end

  def create
    upload = Submission::Upload.create(upload_params.merge(submission_id: submission.id))
    if upload.valid?
      Submission::TraitScoreParser.new(upload).call

      upload = SubmissionUploadDecorator.decorate(upload)

      render json: upload.as_json, status: :created
    else
      errors = upload.errors.messages.map do |attr, messages|
        messages.map do |msg|
          { attribute: attr, message: msg }
        end
      end.flatten

      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def destroy
    upload = submission.uploads.find(params[:id])
    upload.destroy

    render json: {}
  end

  private

  def authenticate_user!
    if request.xhr?
      render json: {}, status: :unauthorized unless user_signed_in?
    else
      super
    end
  end

  def require_submission_owner
    unless current_user.submission_ids.include?(params[:submission_id].to_i)
      render json: {}, status: :not_found
    end
  end

  def submission
    @submission ||= current_user.submissions.find(params[:submission_id])
  end

  def upload_params
    params.require(:submission_upload).permit(:file, :upload_type)
  end
end
