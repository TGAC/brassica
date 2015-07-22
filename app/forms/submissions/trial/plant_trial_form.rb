module Submissions
  module Trial
    class PlantTrialForm < BaseForm
      include Reform::Form::ActiveModel

      model :submission
    end
  end
end
