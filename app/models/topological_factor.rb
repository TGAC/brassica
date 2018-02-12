# Represents topological information as defined in the Crop Research Ontology
# by term CO_715:0000058 and its descendants.
class TopologicalFactor < ActiveRecord::Base
  ROOT_TERM = "CO_715:0000058"

  validates :name, presence: true
  validates :term, presence: true, if: :canonical?

  def parents
    TopologicalFactor.where(id: parent_ids) if parent_ids.present?
  end
end
