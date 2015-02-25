class PlantLinesController < ApplicationController
  include ModelHelper

  def index
    if params[:name]
      render json: plant_lines(params[:name]).map { |r| { id: r, text: r } }
    else
      render json: {}
    end
  end
end
