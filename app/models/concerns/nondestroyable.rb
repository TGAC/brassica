# Provides a Concern for any Model class entities of which should NEVER be destroyed.
# In model class use it with
#   include Nondeletable
# somewhere inside the model class definition. This guards against "destroy", probably
# WARNING: not effective against "delete".

module Nondestroyable extend ActiveSupport::Concern

  included do
    before_destroy :prevent_destroy
  end

  private

  def prevent_destroy
    logger.error "PREVENTING DESTROY of #{self.class.name}!!!"
    raise "Entities of #{self.class.name} cannot be destroyed!"
  end

end
