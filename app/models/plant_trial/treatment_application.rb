# TODO: rename to PlantTrial::Treatment (and find a better name for current PlantTrial::Treatment)
class PlantTrial::TreatmentApplication < ActiveRecord::Base
  self.inheritance_column = :sti_type

  def self.root_term
    PlantTreatmentType::ROOT_TERM
  end

  def self.treatment_types
    PlantTreatmentType.descendants_of(root_term)
  end

  belongs_to :treatment, class_name: "PlantTrial::Treatment"
  belongs_to :treatment_type, ->(treatment_application) { descendants_of(treatment_application.class.root_term) },
    class_name: "PlantTreatmentType"

  validates :treatment, :treatment_type, presence: true
  validates :treatment_type_id, inclusion: { in: ->(treatment_application) { treatment_application.class.treatment_types.pluck(:id) } }
end
