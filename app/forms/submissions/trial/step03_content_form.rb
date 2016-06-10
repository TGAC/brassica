module Submissions
  module Trial
    class Step03ContentForm < PlantTrialForm
      property :lines_or_varieties, writeable: false
      property :technical_replicate_numbers, writeable: false
      property :design_form_names, writeable: false
    end
  end
end
