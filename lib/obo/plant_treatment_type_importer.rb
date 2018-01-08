require "obo"

class Obo::PlantTreatmentTypeImporter
  def initialize(filepath)
    @filepath = filepath
  end

  def import_all
    imported_count = 0

    taxonomy = Obo::Parser.new(@filepath)
    taxonomy.
      elements.
      select { |element| term?(element) }.
      reject { |element| treatment_exists?(element) }.
      each do |element|
        next unless root_treatment?(element) || parent_treatments(element).present?

        import_treatment(element)
        imported_count += 1
      end

    import_all if imported_count > 0
  end

  private

  def term?(element)
    element.is_a?(Obo::Stanza) && element.name == "Term"
  end

  def root_treatment?(element)
    element.id == PlantTreatmentType::ROOT_TERM
  end

  def parent_treatments(element)
    return unless element["is_a"].present?

    PlantTreatmentType.where(term: element["is_a"])
  end

  def import_treatment(element)
    PlantTreatmentType.create!(name: element.tagvalues.fetch("name")[0],
                               term: element.id,
                               canonical: true,
                               parent_ids: parent_treatments(element).pluck(:id))
  end

  def treatment_exists?(element)
    PlantTreatmentType.where(term: element.id).exists?
  end
end
