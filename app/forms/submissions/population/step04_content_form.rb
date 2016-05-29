module Submissions
  module Population
    class Step04ContentForm < PlantPopulationForm
      property :visibility, default: 'published'
      property :data_owned_by
      property :data_provenance
      property :comments

      validates :visibility, inclusion: { in: %w(published private) }
    end
  end
end
