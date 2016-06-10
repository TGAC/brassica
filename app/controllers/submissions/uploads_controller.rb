class Submissions::UploadsController < ApplicationController

  prepend_before_filter :authenticate_user!
  before_filter :require_submission_owner

  def new
    traits = PlantTrialSubmissionDecorator.decorate(submission).sorted_trait_names

    pl_pv_name = if submission.content.step03.lines_or_varieties == 'plant_varieties'
                   'variety'
                 else
                   'line'
                 end

    design_factor_names = submission.content.step03.design_factor_names || []
    design_factors = {
      'A' => design_factor_names.map{ 1 },
      'B' => design_factor_names.map{ 1 }
    }
    if design_factors['B'].present?
      design_factors['B'] = design_factors['B'][0..-2] + [2]
    end

    technical_replicate_numbers = submission.content.step03.technical_replicate_numbers || {}
    traits = traits.map do |trait|
      if technical_replicate_numbers[trait] && technical_replicate_numbers[trait].to_i > 1
        reps_count = [technical_replicate_numbers[trait].to_i, 2].max
        reps_count.times.map { |rep| "#{trait}_rep#{rep + 1}" }
      else
        trait
      end
    end.flatten

    data = CSV.generate(headers: true) do |csv|
      csv << ['Plant scoring unit name'] + design_factor_names + ['Plant accession', 'Originating organisation', "Plant #{pl_pv_name}"] + traits

      ['A','B'].each do |sample|
        sample_values = traits.map.with_index do |trait,i|
          if technical_replicate_numbers[trait] && technical_replicate_numbers[trait].to_i > 1
            reps_count = [technical_replicate_numbers[trait].to_i, 2].max
            reps_count.times.map { |rep| "sample_#{sample}_rep#{rep + 1}_value_for_#{trait}__replace_it" }
          else
            "sample_#{sample}_value_for_#{trait}__replace_it"
          end
        end
        csv << ["Sample scoring unit #{sample} name - replace it"] +
               design_factors[sample] +
               ['Accession identifier - replace it',
                'Organisation name or acronym - replace it',
                "Plant #{pl_pv_name} name - replace it"] +
               sample_values
      end
    end

    send_data data,
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
    Submission::TraitScoreParser.new(upload).call if upload.trait_scores?
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
