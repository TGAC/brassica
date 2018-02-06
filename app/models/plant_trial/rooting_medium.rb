class PlantTrial::RootingMedium < ActiveRecord::Base
  # TODO: Should really reference PlantTreatmentTypes? Perhaps distinct model/table would be more appropriate.
  def self.root_term
    PlantTreatmentType::GROWTH_MEDIUM_ROOT_TERM
  end

  belongs_to :environment, class_name: "PlantTrial::Environment"
  belongs_to :medium_type, -> { descendants_of(PlantTrial::RootingMedium.root_term) },
    class_name: "PlantTreatmentType"

  validates :environment, :medium_type, presence: true
  validates :medium_type, inclusion: { in: ->(_) { PlantTreatmentType.descendants_of(PlantTrial::RootingMedium.root_term) } }
end
