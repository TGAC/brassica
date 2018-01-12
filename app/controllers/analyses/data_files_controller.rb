class Analyses::DataFilesController < ApplicationController
  prepend_before_filter :authenticate_user!

  rescue_from Encoding::InvalidByteSequenceError do
    render json: { errors: ["Invalid file encoding. Expected plain-text or UTF-8 encoded file."] }, status: 422
  end

  def new
    data_type = params[:data_type]
    generator = case data_type
                when "gwas_genotype"
                  Analysis::Gwasser::GenotypeCsvTemplateGenerator.new(plant_trial)
                when "gwas_phenotype"
                  Analysis::Gwasser::PhenotypeCsvTemplateGenerator.new
                when "gwas_map"
                  Analysis::Gwasser::MapCsvTemplateGenerator.new
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

    postprocess_data_file(data_file) if data_file.valid?

    render json: decorate_data_file(data_file), status: data_file.valid? ? :created : :unprocessable_entity
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
      merge(owner: current_user, origin: "uploaded")
  end

  def postprocess_data_file(data_file)
    return unless data_file.file_format == "csv" && data_file.gwas_genotype?

    CSV::Transpose.new(data_file.file.path).call(force_quotes: true)
  end

  def decorate_data_file(data_file)
    AnalysisDataFileDecorator.decorate(data_file)
  end

  def plant_trial
    PlantTrial.visible(current_user.id).find(params[:plant_trial_id]) if params[:plant_trial_id].present?
  end
end
