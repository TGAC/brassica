module Submissions
  module Population
    class Step05ContentForm < PlantPopulationForm
      property :visibility, default: 'private'
      property :data_owned_by
      property :data_provenance
      property :comments

      validates :visibility, inclusion: { in: %w(published private) }
    end
  end
end
