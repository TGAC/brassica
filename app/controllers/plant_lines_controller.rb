class PlantLinesController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json do
        render json: data_grid
      end
    end
  end


  private

  def data_grid
    plant_lines = PlantLine.grid_data(params[:plant_line_names])

    {
      draw: 1,
      recordsTotal: plant_lines.size,
      recordsFiltered: plant_lines.size,
      data: plant_lines
    }
  end
end
