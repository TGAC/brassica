class PlantPopulationsController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json do
        plant_populations = PlantPopulation.grouped
        grid_data = ApplicationDecorator.decorate(plant_populations)
        render json: grid_data.as_grid_data
      end
    end
  end
end
