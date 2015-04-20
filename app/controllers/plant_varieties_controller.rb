class PlantVarietiesController < ApplicationController

  def index
    render json: PlantVariety.filter(params)
  end

end

