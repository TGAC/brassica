module ModelHelper
  def population_types
    PopulationType.population_types
  end

  def plant_lines(name = nil)
    results = PlantLine.order(:plant_line_name)
    results = results.where('plant_line_name ILIKE ?', "%#{name}%")
    results.pluck(:plant_line_name)
  end
end
