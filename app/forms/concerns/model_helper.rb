module ModelHelper
  def population_types
    ["Type A", "Type B", "Type C"]
  end

  def plant_lines(name = nil)
    # FIXME replace with proper AR query
    query = "SELECT plant_line_name FROM plant_lines "
    query += "WHERE plant_line_name ILIKE '%#{name}%'" if name
    results = ActiveRecord::Base.connection.select_all(query)
    results.map { |r| r['plant_line_name'] }
  end

  def taxonomy_terms
    TaxonomyTerm.pluck(:name).unshift(nil)
  end
end
