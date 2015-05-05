# NOTE it does not do anything at this moment but will be used to expose
# associations
class Api::Decorator < Draper::Decorator
  delegate_all
end
