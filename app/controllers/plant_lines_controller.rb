class PlantLinesController < ApplicationController
  def index
  end

  def data_grid
    @plant_lines = PlantLine.grid_data(params[:plant_line_names])

    response = {
      draw: 1,
      recordsTotal: @plant_lines.size,
      recordsFiltered: @plant_lines.size,
      data: @plant_lines
    }

    render json: response, layout: false
  end
end
