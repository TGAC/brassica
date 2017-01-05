class Submissions::UploadsController < ApplicationController

  prepend_before_filter :authenticate_user!
  before_filter :require_submission_owner

  def new
    send_data Submission::TraitScoreTemplateGenerator.new(submission).call,
              content_type: 'text/csv; charset=UTF-8; header=present',
              disposition: 'attachment; filename=plant_trial_scoring_data.csv'
  end

  def create
    upload = Submission::Upload.create(upload_params.merge(submission_id: submission.id))

    if upload.valid?
      process_upload(upload)

      render json: decorate_upload(upload), status: :created
    else
      render json: decorate_upload(upload), status: :unprocessable_entity
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

  def process_upload(upload)
    if upload.trait_scores?
      Submission::TraitScoreParser.new(upload).call
    elsif upload.plant_lines?
      Submission::PlantLineParser.new(upload).call
    end
  end

  def decorate_upload(upload)
    case
    when upload.trait_scores?
      SubmissionTraitScoresUploadDecorator.decorate(upload)
    when upload.plant_trial_layout?
      SubmissionPlantTrialLayoutUploadDecorator.decorate(upload)
    else
      SubmissionUploadDecorator.decorate(upload)
    end
  end
end
