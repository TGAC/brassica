class PlantPopulationsController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json do
        grid_data = PlantPopulationsDecorator.decorate(PlantPopulation.grid_data)
        render json: grid_data.as_grid_data
      end
    end
  end
end
