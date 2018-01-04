# Models "Type of lamps used" attribute as defined by MIAPPE.
class PlantTrial::Lamp < ActiveRecord::Base
  self.table_name = "plant_trial_lamps"

  belongs_to :environment, class_name: "PlantTrial::Environment"
  belongs_to :lamp_type

  validates :environment, presence: true
  validates :lamp_type, presence: true, if: -> { description.blank? }
  validates :description, presence: true, if: -> { lamp_type.blank? }
end
