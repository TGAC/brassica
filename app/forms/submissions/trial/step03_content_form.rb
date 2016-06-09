module Submissions
  module Trial
    class Step03ContentForm < PlantTrialForm
      # NOTE: needed because completely empty step breaks submission
      property :_i_am_fake
    end
  end
end
