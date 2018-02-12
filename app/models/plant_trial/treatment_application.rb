class PlantTrial::TreatmentApplication < ActiveRecord::Base
  self.inheritance_column = :sti_type

  belongs_to :treatment, class_name: "PlantTrial::Treatment"
  belongs_to :treatment_type, -> { descendants_of(root_term) }, class_name: "PlantTreatmentType"

  validates :treatment, :treatment_type, presence: true

  def self.root_term
    PlantTreatmentType::ROOT_TERM
  end
end
