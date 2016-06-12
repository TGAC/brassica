module Submissions
  module Trial
    class Step03ContentForm < PlantTrialForm
      property :lines_or_varieties
      collection :technical_replicate_numbers
      collection :design_factor_names

      # TODO: validate technical_replicate_numbers, each > 1
    end
  end
end
