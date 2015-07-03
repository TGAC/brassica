class Submissions::UploadsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :require_submission_owner

  def create
    upload = Submission::Upload.create(upload_params.merge(submission_id: submission.id))
    if upload.valid?

      # TODO process uploaded file

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

  private

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
