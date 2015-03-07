class PlantPopulationSubmissionDecorator < Draper::Decorator
  delegate_all

  def label
    "".tap do |l|
      l << "Population: #{population_name}" if population_name
      l << " (#{species_name})" if species_name
      l << "." if population_name || species
      l << " #{population_type}." if population_type
      l << " Parents: #{parent_line_names.join(" | ")}" if parent_line_names
    end.strip
  end

  def population_name
    @population_name ||= object.content.step01.name.presence
  end

  def species_name
    return @species_name if defined?(@species_name)

    if species.present? && ! ['undefined', 'none', 'not_applicable'].include?(species)
      @species_name = "B. #{species}"
    end
  end

  def species
    @species ||= plant_line.try(:species)
  end

  def population_type
    @population_type ||= object.content.step02.population_type.presence
  end

  def plant_line
    return @plant_line if defined?(@plant_line)
    return if ! plant_line_name
    @plant_line = PlantLine.find_by(plant_line_name: plant_line_name)
  end

  def plant_line_name
    @plant_line_name ||= object.content.step02.plant_line.presence
  end

  def parent_line_names
    [female_parent_line_name, male_parent_line_name].compact.select(&:present?)
  end

  def female_parent_line_name
    object.content.step03.female_parent_line.presence
  end

  def male_parent_line_name
    object.content.step03.male_parent_line.presence
  end

  def description
    object.content.step01.description.presence
  end

  def owned_by
    object.content.step01.owned_by.presence
  end

  def data_owned_by
    object.content.step04.data_owned_by.presence
  end

  def data_provenance
    object.content.step04.data_provenance.presence
  end

  def comments
    object.content.step04.comments.presence
  end
end
