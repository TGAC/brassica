class Search

  attr_accessor :query

  def initialize(query)
    self.query = "#{query}*"
  end

  def counts
    {
      plant_populations: plant_populations.count,
      plant_lines: plant_lines.count,
      plant_varieties: plant_varieties.count
    }
  end

  def all
    {
      plant_populations: plant_populations,
      plant_lines: plant_lines,
      plant_varieties: plant_varieties
    }
  end

  def plant_populations
    PlantPopulation.search(query, size: PlantPopulation.count)
  end

  def plant_lines
    PlantLine.search(query, size: PlantLine.count)
  end

  def plant_varieties
    PlantVariety.search(query, size: PlantVariety.count)
  end
end
