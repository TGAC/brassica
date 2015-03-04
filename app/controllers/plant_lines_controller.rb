class PlantLinesController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json do
        plant_lines = PlantLine.grid_data(params[:plant_line_names])
        grid_data = ApplicationDecorator.decorate(plant_lines)
        render json: grid_data.as_grid_data
      end
    end
  end
end
