class DataTablesController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        model_param
      end
      format.json do
        objects = model_param.singularize.camelize.constantize.table_data(params)
        grid_data = ApplicationDecorator.decorate(objects)
        render json: grid_data.as_grid_data
      end
    end
  end

  def show
    object = model_param.singularize.camelize.constantize.find(params[:id])
    render json: object.annotations_as_json
  end

  private

  def model_param
    if params[:model].present? && !allowed_models.include?(params[:model])
      raise ActionController::RoutingError.new('Not Found')
    end
    params.require(:model)
  end

  def allowed_models
    %w(plant_trials trait_descriptors plant_lines plant_populations 
       plant_varieties trait_scores linkage_maps qtl plant_scoring_units)
  end
end
