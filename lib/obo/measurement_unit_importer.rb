require "obo"

class Obo::MeasurementUnitImporter
  def initialize(filepath)
    @filepath = filepath
  end

  def import_all
    imported_count = 0

    ontology = Obo::Parser.new(@filepath)
    ontology.
      elements.
      select { |element| term?(element) }.
      reject { |element| unit_exists?(element) }.
      each do |element|
        next unless root_unit?(element) || parent_units(element).present?

        import_unit(element)
        imported_count += 1
      end

    import_all if imported_count > 0
  end

  private

  def term?(element)
    element.is_a?(Obo::Stanza) && element.name == "Term"
  end

  def root_unit?(element)
    element.id == MeasurementUnit::ROOT_TERM
  end

  def parent_units(element)
    return MeasurementUnit.none unless element["is_a"].present?

    MeasurementUnit.where(term: element["is_a"])
  end

  def import_unit(element)
    MeasurementUnit.create!(name: element.tagvalues.fetch("name")[0],
                            description: element.tagvalues.fetch("def")[0],
                            term: element.id,
                            canonical: true,
                            parent_ids: parent_units(element).pluck(:id))
  end

  def unit_exists?(element)
    MeasurementUnit.where(term: element.id).exists?
  end
end
