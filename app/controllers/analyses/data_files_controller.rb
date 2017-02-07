class Analyses::DataFilesController < ApplicationController
  prepend_before_filter :authenticate_user!

  def new
    # send_data Submission::TraitScoreTemplateGenerator.new(submission).call,
    #           content_type: 'text/csv; charset=UTF-8; header=present',
    #           disposition: 'attachment; filename=plant_trial_scoring_data.csv'
  end

  def create
    data_file = Analysis::DataFile.create(create_params)

    if data_file.valid?
      # process_data_file(data_file)

      render json: decorate_data_file(data_file), status: :created
    else
      render json: decorate_data_file(data_file), status: :unprocessable_entity
    end
  end

  def destroy
    data_file = current_user.data_files.find(params[:id])
    data_file.destroy

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

  def create_params
    params.
      require(:analysis_data_file).
      permit(:file, :data_type).
      merge(owner: current_user)
  end

  def decorate_data_file(data_file)
    AnalysisDataFileDecorator.decorate(data_file)
  end
end
