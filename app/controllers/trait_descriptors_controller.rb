class TraitDescriptorsController < ApplicationController

  def index
    descriptors = TraitDescriptor.where("descriptor_name ILIKE ?", "%#{params[:search][:descriptor_name]}%")

    render json: descriptors
  end

end
