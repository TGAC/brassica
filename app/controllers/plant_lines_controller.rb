class PlantLinesController < ApplicationController

  def index
    render json: PlantLine.filter(params)
  end

end
