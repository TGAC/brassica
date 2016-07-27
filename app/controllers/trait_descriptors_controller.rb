class TraitDescriptorsController < ApplicationController

  def index
    page = params[:page] || 1
    descriptors = TraitDescriptor.includes(:trait).references(:trait)
    descriptors = descriptors.where("traits.name ILIKE ?", "%#{params[:search][:trait_name]}%")
    descriptors = descriptors.visible(current_user.try(:id))
    descriptors = descriptors.order('traits.name')

    render json: {
      results: descriptors.page(page),
      page: page,
      per_page: Kaminari.config.default_per_page,
      total_count: descriptors.count
    }
  end

end
