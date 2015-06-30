class TraitDescriptorsController < ApplicationController

  def index
    # TODO FIXME This does not properly filter only relevant things!
    # TODO FIXME Also - is this susceptible to code injection or not?
    render json: TraitDescriptor.where("descriptor_name ILIKE ?", "%#{params[:descriptor_name]}%")
  end

end
