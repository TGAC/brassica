module Submissions
  class Step01ContentForm < BaseForm
    property :name
    property :description
    property :owned_by

    validates :name, presence: true

    validate do
      if PlantPopulation.where(name: name).exists?
        errors.add(:name, :taken)
      end
    end
  end
end
