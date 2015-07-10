# FIXME merge all autocomplete related controllers
class PlantPopulationsController < ApplicationController

  def index
    render json: PlantPopulation.filter(params)
  end

end
