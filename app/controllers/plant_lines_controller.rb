class PlantLinesController < ApplicationController

  def index
    respond_to do |format|
      format.html
      format.json do
        plant_lines = PlantLine.filtered(params)
        grid_data = ApplicationDecorator.decorate(plant_lines)
        render json: grid_data.as_grid_data
      end
    end
  end
end
