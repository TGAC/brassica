class PlantTrial::TopologicalDescriptor < ApplicationRecord
  self.table_name = "plant_trial_topological_descriptors"

  belongs_to :environment, class_name: "PlantTrial::Environment"
  belongs_to :topological_factor

  validates :environment, :topological_factor, :description, presence: true
  validates :topological_factor, uniqueness: { scope: :environment_id }
end
