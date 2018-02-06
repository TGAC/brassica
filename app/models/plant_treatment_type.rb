# Represents a plant treatment as defined in the Plant Experimental Conditions
# Ontology by term PECO:0001001 and its descendants.
class PlantTreatmentType < ActiveRecord::Base
  ROOT_TERM = "PECO:0001001"
  BIOTIC_ROOT_TERM = "PECO:0007357"
  CHEMICAL_ROOT_TERM = "PECO:0007189"
  ANTIBIOTIC_ROOT_TERM = "PECO:0007041"
  HERBICIDE_ROOT_TERM = "PECO:0007183"
  FUNGICIDE_ROOT_TERM = "PECO:0007268"
  PESTICIDE_ROOT_TERM = "PECO:0007167"
  HORMONE_ROOT_TERM = "PECO:0007165"
  FERTILIZER_ROOT_TERM = "PECO:0007085"
  GROWTH_MEDIUM_ROOT_TERM = "PECO:0007147"
  SOIL_ROOT_TERM = "PECO:0007049"
  SOIL_TEMPERATURE_ROOT_TERM = "BIP-SOIL-TEMPERATURE"
  GASEOUS_ROOT_TERM = "PECO:0007023"
  MECHANICAL_ROOT_TERM = "PECO:0007373"
  SALT_ROOT_TERM = "PECO:0007185"
  SEASONAL_ROOT_TERM = "PECO:0007027"
  HUMIDITY_ROOT_TERM = "PECO:0007197"
  RAINFALL_ROOT_TERM = "PECO:0007181"
  WATERING_ROOT_TERM = "PECO:0007383"
  GRAVITY_ROOT_TERM = "PECO:0007146"
  RADIATION_ROOT_TERM = "PECO:0007151"
  PH_ROOT_TERM = "PECO:0007171"
  AIR_ROOT_TERM = "PECO:0007161"
  WATER_TEMPERATURE_ROOT_TERM = "PECO:0007160"

  validates :name, presence: true
  validates :term, presence: true, if: :canonical?

  def self.descendants_of(term)
    term = term.term if term.is_a?(self)

    query = <<-SQL.strip_heredoc
      WITH RECURSIVE descendant_plant_treatment_types(id, parent_ids, name, term)
      AS (
        SELECT ptt.id, ptt.parent_ids, ptt.name, ptt.term
        FROM plant_treatment_types ptt WHERE ptt.term = ?
      UNION ALL
        SELECT ptt.id, ptt.parent_ids, ptt.name, ptt.term
        FROM plant_treatment_types ptt, descendant_plant_treatment_types dptt
        WHERE dptt.id = ANY(ptt.parent_ids)
      )
      SELECT id FROM descendant_plant_treatment_types
    SQL

    where("id IN (#{query})", term)
  end

  def parents
    PlantTreatmentType.where(id: parent_ids) if parent_ids.present?
  end
end
