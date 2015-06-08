module Submissions
  class PlantPopulationForm < BaseForm
    include Reform::Form::ActiveModel

    model :submission
  end
end
