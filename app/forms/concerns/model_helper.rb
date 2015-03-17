module ModelHelper
  def population_types
    PopulationTypeLookup.order(:population_type).pluck(:population_type)
  end

  def plant_lines(name = nil)
    results = PlantLine.order(:plant_line_name)
    results = results.where('plant_line_name ILIKE ?', "%#{name}%")
    results.pluck(:plant_line_name)
  end
end
