class PlantVarietiesController < ApplicationController
  def index
    page = params[:page] || 1
    plant_varieties = PlantVariety.filter(params).visible(current_user.try(:id)).order(:plant_variety_name)
    render json: {
      results: plant_varieties.page(page),
      page: page,
      per_page: Kaminari.config.default_per_page,
      total_count: plant_varieties.count
    }
  end
end

