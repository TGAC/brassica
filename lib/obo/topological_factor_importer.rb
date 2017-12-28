require "obo"

class Obo::TopologicalFactorImporter
  def initialize(filepath)
    @filepath = filepath
  end

  def import_all
    imported_count = 0

    ontology = Obo::Parser.new(@filepath)
    ontology.
      elements.
      select { |element| term?(element) }.
      reject { |element| factor_exists?(element) }.
      each do |element|
        next unless root_factor?(element) || parent_factors(element).present?

        import_factor(element)
        imported_count += 1
      end

    import_all if imported_count > 0
  end

  private

  def term?(element)
    element.is_a?(Obo::Stanza) && element.name == "Term"
  end

  def root_factor?(element)
    element.id == TopologicalFactor::ROOT_TERM
  end

  def parent_factors(element)
    return unless element["is_a"].present?

    TopologicalFactor.where(term: element["is_a"])
  end

  def import_factor(element)
    TopologicalFactor.create!(name: element.tagvalues.fetch("name")[0],
                              term: element.id,
                              parent_ids: parent_factors(element).pluck(:id))
  end

  def factor_exists?(element)
    TopologicalFactor.where(term: element.id).exists?
  end
end
