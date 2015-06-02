module Submissions
  class Step01ContentForm < BaseForm
    property :name
    property :description
    property :owned_by

    validates :name, presence: { message: I18n.t('submission.errors.population_name_missing')}

    validate do
      if PlantPopulation.where(name: name).exists?
        errors.add(:name, I18n.t('submission.errors.population_name_taken'))
      end
    end
  end
end
