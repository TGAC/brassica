# Models "Container type" attribute as defined by MIAPPE.
class PlantTrial::Container < ActiveRecord::Base
  self.table_name = "plant_trial_containers"

  belongs_to :environment, class_name: "PlantTrial::Environment"
  belongs_to :container_type

  validates :environment, presence: true
  validates :container_type, presence: true, if: -> { description.blank? }
  validates :description, presence: true, if: -> { container_type.blank? }
end
