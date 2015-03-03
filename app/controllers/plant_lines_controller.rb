class PlantLinesController < ApplicationController
  include ModelHelper

  # FIXME temporary, to be merged with plant_populations_data_grid branch
  def index
    if params[:name]
      render json: plant_lines(params[:name]).map { |r| { id: r, text: r } }
    else
      render json: {}
    end
  end
end
