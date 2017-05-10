class Analyses::DataFilesController < ApplicationController
  prepend_before_filter :authenticate_user!

  def new
    data_type = params[:data_type]
    generator = case data_type
                when "gwas_genotype"
                  Analysis::Gwas::GenotypeCsvTemplateGenerator.new(plant_trial)
                when "gwas_phenotype"
                  Analysis::Gwas::PhenotypeCsvTemplateGenerator.new
                when "gwas_map"
                  Analysis::Gwas::MapCsvTemplateGenerator.new
                end

    if generator
      send_data generator.call,
        content_type: 'text/csv; charset=UTF-8; header=present',
        disposition: "attachment; filename=#{data_type.dasherize}-template.csv"
    else
      render nothing: true
    end
  end

  def create
    data_file = Analysis::DataFile.create(create_params)

    render json: decorate_data_file(data_file),
      status: data_file.valid? ? :created : :unprocessable_entity
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

  def plant_trial
    PlantTrial.visible(current_user.id).find(params[:plant_trial_id]) if params[:plant_trial_id].present?
  end
end
