module Submissions
  module Population
    class PlantPopulationForm < BaseForm
      include Reform::Form::ActiveModel

      model :submission
    end
  end
end
