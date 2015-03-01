class PlantPopulationsController < ApplicationController
  def index
  end

  def data_grid
    @plant_populations = PlantPopulation.grid_data
    data = @plant_populations.map do |pp,c|
      pp + [c]
    end

    response = {
      draw: 1,
      recordsTotal: @plant_populations.size,
      recordsFiltered: @plant_populations.size,
      data: data
    }

    render json: response, layout: false
  end
end
