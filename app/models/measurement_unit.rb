class MeasurementUnit < ActiveRecord::Base
  ROOT_TERM = "UO:0000000"

  validates :name, :description, presence: true
  validates :term, presence: true, if: :canonical?
  validates :term, uniqueness: true, if: :canonical?

  def self.descendants_of(term)
    term = term.term if term.is_a?(self)

    query = <<-SQL.strip_heredoc
      WITH RECURSIVE descendant_measurement_units(id, parent_ids, name, term)
      AS (
        SELECT mu.id, mu.parent_ids, mu.name, mu.term
        FROM measurement_units mu WHERE mu.term = ?
      UNION ALL
        SELECT mu.id, mu.parent_ids, mu.name, mu.term
        FROM measurement_units mu, descendant_measurement_units dmu
        WHERE dmu.id = ANY(mu.parent_ids)
      )
      SELECT id FROM descendant_measurement_units
    SQL

    where("id IN (#{query})", term)
  end

  def parents
    MeasurementUnit.where(id: parent_ids) if parent_ids.present?
  end
end
