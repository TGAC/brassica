module Submissions
  module Trial
    class Step04ContentForm < PlantTrialForm
      property :publishability, default: 'publishable'
      property :data_owned_by
      property :data_provenance
      property :comments

      validates :publishability, inclusion: { in: %w(publishable private) }
    end
  end
end
