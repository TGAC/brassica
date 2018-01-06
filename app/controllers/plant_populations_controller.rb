class PlantPopulationsController < ApplicationController
  def index
    page = params[:page] || 1
    plant_populations = PlantPopulation.filter(params).visible(current_user.try(:id)).order(:name)
    render json: {
      results: plant_populations.page(page),
      page: page,
      per_page: Kaminari.config.default_per_page,
      total_count: plant_populations.count
    }
  end
end
