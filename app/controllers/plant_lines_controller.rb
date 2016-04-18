class PlantLinesController < ApplicationController

  def index
    page = params[:page] || 1
    plant_lines = PlantLine.filter(params).visible(current_user.try(:id)).order(:plant_line_name)
    render json: {
      results: plant_lines.page(page),
      page: page,
      per_page: Kaminari.config.default_per_page,
      total_count: plant_lines.count
    }
  end

end
