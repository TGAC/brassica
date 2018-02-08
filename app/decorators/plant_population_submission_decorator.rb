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
      l << h.content_tag(:span, population_type, class: 'details')
      if parent_line_names.present?
        l << h.content_tag(:span, 'Parents: ', class: 'text')
        l << h.content_tag(:span, parent_line_names.join(" | "), class: 'details')
      end
    end.strip
  end

  def name
    population_name || ''
  end

  def population_name
    @population_name ||= object.content.name.presence
  end

  def establishing_organisation
    @establishing_organisation ||= object.content.establishing_organisation.presence
  end

  def species_name
    taxonomy_term
  end

  def taxonomy_term
    @taxonomy_term ||= object.content.taxonomy_term.presence
  end

  def population_type
    @population_type ||= object.content.population_type.presence
  end

  def plant_lines
    plant_line_ids = plant_line_list.select { |el| el.to_i.to_s == el }
    return [] if plant_line_ids.blank?
    @plant_lines ||= PlantLine.visible(user_id).find(plant_line_ids)
  end

  def plant_line_names
    @plant_line_names ||=
      plant_lines.map(&:plant_line_name) | plant_line_list.reject { |el| el.to_i.to_s == el }
  end

  def plant_line_list
    object.content.plant_line_list || []
  end

  def parent_line_names
    [female_parent_line_name, male_parent_line_name].compact.select(&:present?)
  end

  def female_parent_line
    return if female_parent_line_name.blank?
    PlantLine.visible(user_id).find_by!(plant_line_name: female_parent_line_name)
  end

  def male_parent_line
    return if male_parent_line_name.blank?
    PlantLine.visible(user_id).find_by!(plant_line_name: male_parent_line_name)
  end

  def female_parent_line_name
    object.content.female_parent_line.presence
  end

  def male_parent_line_name
    object.content.male_parent_line.presence
  end

  def description
    object.content.description.presence || ''
  end

  def affiliation
    owned_by || ''
  end

  def owned_by
    object.content.owned_by.presence
  end

  def data_owned_by
    object.content.data_owned_by.presence
  end

  def data_provenance
    object.content.data_provenance.presence
  end

  def comments
    object.content.comments.presence
  end

  def submission_attributes
    [
      [:population_name, "Population name", h.data_tables_path(model: :plant_populations, query: { id: submitted_object_id })],
      [:description],
      [:owned_by],
      [:establishing_organisation],
      [:population_type],
      [:species_name, "Species"],
      [:plant_line_names, 'Plant lines', h.data_tables_path(model: :plant_lines, query: { "plant_populations.id": submitted_object_id })],
      [:female_parent_line_name, 'Female parent line', h.data_tables_path(model: :plant_lines, query: { id: female_parent_line.try(:id) })],
      [:male_parent_line_name, 'Male parent line', h.data_tables_path(model: :plant_lines, query: { id: male_parent_line.try(:id) })],
      [:data_owned_by],
      [:data_provenance],
      [:comments],
      [:doi, 'DOI']
    ]
  end
end
