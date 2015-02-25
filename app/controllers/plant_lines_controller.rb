class PlantLinesController < ApplicationController
  def index
    if params[:name]
      # FIXME replace with proper AR query
      results = ActiveRecord::Base.connection.select_all("SELECT plant_line_name FROM plant_lines WHERE plant_line_name ILIKE '%#{params[:name]}%'")

      render json: results.map { |r| r['plant_line_name'] }
    else
      render json: {}
    end
  end
end
