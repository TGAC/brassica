class PlantTrialsController < ApplicationController

  def index
    page = params[:page] || 1
    plant_trials = PlantTrial.filter(params).visible(current_user.try(:id)).order(:plant_trial_name)
    render json: {
      results: plant_trials.page(page),
      page: page,
      per_page: Kaminari.config.default_per_page,
      total_count: plant_trials.count
    }
  end

end
