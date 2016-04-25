class Submissions::UploadsController < ApplicationController

  prepend_before_filter :authenticate_user!
  before_filter :require_submission_owner

  def new
    @traits = PlantTrialSubmissionDecorator.decorate(submission).sorted_trait_names

    data = CSV.generate(headers: true) do |csv|
      csv << ['Plant scoring unit name'] + @traits

      ['A','B'].each do |sample|
        sample_values = @traits.map.with_index{ |_,i| "sample_#{sample}_value_#{i}__replace_it" }
        csv << ["sample_scoring_unit_#{sample}_name__replace_it"] + sample_values
      end
    end

    send_data data,
              content_type: 'text/csv; charset=UTF-8; header=present',
              disposition: 'attachment; filename=plant_trial_scoring_data.csv'
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
