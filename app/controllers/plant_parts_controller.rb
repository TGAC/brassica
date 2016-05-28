class PlantPartsController < ApplicationController
  def index
    page = params[:page] || 1
    plant_parts = PlantPart.filter(params).order(:plant_part)
    render json: {
      results: plant_parts.page(page),
      page: page,
      per_page: Kaminari.config.default_per_page,
      total_count: plant_parts.count
    }
  end
end
