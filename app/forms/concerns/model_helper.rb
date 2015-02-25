module ModelHelper
  def population_types
    ["Type A", "Type B", "Type C"]
  end

  def plant_lines
    ["Line X", "Line Y", "Line Z"]
  end

  def taxonomy_terms
    @taxonomy_terms ||= TaxonomyTerm.pluck(:name)
  end
end
