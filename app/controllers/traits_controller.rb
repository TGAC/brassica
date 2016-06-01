class TraitsController < ApplicationController
  def index
    page = params[:page] || 1
    traits = Trait.filter(params).order(:name)
    render json: {
      results: traits.page(page),
      page: page,
      per_page: Kaminari.config.default_per_page,
      total_count: traits.count
    }
  end
end
