module Submissions
  module Population
    class Step04ContentForm < PlantPopulationForm
      property :publishability, default: 'publishable'
      property :data_owned_by
      property :data_provenance
      property :comments

      validates :publishability, inclusion: { in: %w(publishable private) }
    end
  end
end
