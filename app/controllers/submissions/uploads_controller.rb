class Submissions::UploadsController < ApplicationController

  prepend_before_filter :authenticate_user!
  before_filter :require_submission_owner

  def new
    send_data Submission::TraitScoreTemplateGenerator.new(submission).call,
              content_type: 'text/csv; charset=UTF-8; header=present',
              disposition: 'attachment; filename=plant_trial_scoring_data.csv'
  end

  def create
    upload = decorate_upload(create_upload)

    if upload.valid?
      process_upload(upload)

      render json: upload, status: :created
    else
      render json: upload, status: :unprocessable_entity
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

  def create_upload
    Submission::Upload.create(upload_params.merge(submission_id: submission.id))
  end

  def upload_params
    params.require(:submission_upload).permit(:file, :upload_type)
  end

  def process_upload(upload)
    processors = {
      "trait_scores" => Submission::TraitScoreParser,
      "plant_lines" => Submission::PlantLineParser,
      "plant_trial_environment" => Submission::PlantTrialEnvironmentProcessor,
      "plant_trial_treatment" => Submission::PlantTrialTreatmentProcessor
    }

    return unless processors.key?(upload.upload_type)

    processors.fetch(upload.upload_type).new(upload).call
  end

  def decorate_upload(upload)
    decorators = {
      "trait_scores" => SubmissionTraitScoresUploadDecorator,
      "plant_lines" => SubmissionPlantLinesUploadDecorator,
      "plant_trial_environment" => SubmissionPlantTrialEnvironmentUploadDecorator,
      "plant_trial_treatment" => SubmissionPlantTrialTreatmentUploadDecorator,
      "plant_trial_layout" => SubmissionPlantTrialLayoutUploadDecorator
    }

    return SubmissionUploadDecorator.decorate(upload) unless decorators.key?(upload.upload_type)

    decorators.fetch(upload.upload_type).decorate(upload)
  end
end
