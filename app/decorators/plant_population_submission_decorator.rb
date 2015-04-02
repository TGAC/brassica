class PlantPopulationSubmissionDecorator < SubmissionDecorator
  delegate_all

  def label
    h.content_tag(
      :span,
      ''.tap do |l|
        l << population_name if population_name
        l << " (#{species_name})" if species_name
        l << I18n.t('submission.empty_label') unless population_name || species_name
      end.strip,
      class: 'title'
    )
  end

  def further_details
    ''.tap do |l|
      l << h.content_tag(:span, population_type, class: 'details') if population_type
      if parent_line_names.present?
        l << h.content_tag(:span, 'Parents: ', class: 'text')
        l << h.content_tag(:span, parent_line_names.join(" | "), class: 'details')
      end
    end.strip
  end

  def details_path
    Rails.application.routes.url_helpers.data_tables_path(
      model: :plant_populations,
      query: {
        plant_population_id: population_name
      }
    )
  end


  def population_name
    @population_name ||= object.content.step01.name.presence
  end

  def species_name
    taxonomy_term
  end

  def taxonomy_term
    @taxonomy_term ||= object.content.step02.taxonomy_term.presence
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
