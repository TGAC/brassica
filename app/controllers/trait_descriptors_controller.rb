class TraitDescriptorsController < ApplicationController

  def index
    page = params[:page] || 1
    descriptors = TraitDescriptor.where("descriptor_name ILIKE ?", "%#{params[:search][:descriptor_name]}%")
    descriptors = descriptors.order(:descriptor_name)

    render json: {
      results: descriptors.page(page),
      page: page,
      per_page: Kaminari.config.default_per_page,
      total_count: descriptors.count
    }
  end

end
