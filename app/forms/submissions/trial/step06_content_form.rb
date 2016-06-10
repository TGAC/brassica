module Submissions
  module Trial
    class Step06ContentForm < PlantTrialForm
      property :visibility, default: 'published'
      property :data_owned_by
      property :data_provenance
      property :comments

      validates :visibility, inclusion: { in: %w(published private) }
    end
  end
end
