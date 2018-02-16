class PlantTrialSubmissionDecorator < SubmissionDecorator
  delegate_all

  def label
    h.content_tag(
      :span,
      ''.tap do |l|
        l << plant_trial_name if plant_trial_name
        l << " (#{species_name})" if species_name
        l << I18n.t('submission.empty_label') unless plant_trial_name || species_name
      end.strip,
      class: 'title'
    )
  end

  def further_details
    ''.tap do |l|
      l << h.content_tag(:span, project_descriptor, class: 'details')
      if trait_descriptors.present?
        l << h.content_tag(:span, 'Traits scored: ', class: 'text')
        l << h.content_tag(:span, trait_descriptors.join(" | "), class: 'details')
      end
    end.strip
  end

  def name
    plant_trial_name || ''
  end

  def plant_trial_name
    @plant_trial_name ||= object.content.plant_trial_name.presence
  end

  def project_descriptor
    @project_descriptor ||= object.content.project_descriptor.presence
  end

  def species_name
    plant_population.try(:taxonomy_term).try(:name)
  end

  def plant_population
    return @plant_population if defined?(@plant_population)
    return if object.content.plant_population_id.blank?
    @plant_population = PlantPopulation.find_by(id: object.content.plant_population_id)
  end

  def trait_descriptors
    tds = object.content.trait_descriptor_list.try(:select, &:present?) || []
    existing_tds = tds.select { |td| td.to_s.match(/\A\d+\z/) }
    new_tds = tds - existing_tds
    new_tds | TraitDescriptor.includes(:trait).references(:trait).where(id: existing_tds).pluck('traits.name')
  end

  # Takes new TD names and hits the DB for old TDs for their names; sorts
  def sorted_trait_names
    return @sorted_trait_names if @sorted_trait_names
    trait_list = object.content.trait_descriptor_list || []
    @sorted_trait_names = trait_list.compact.map do |trait_item|
      if trait_item.to_i.to_s != trait_item.to_s
        trait_item
      else
        trait_descriptor = TraitDescriptor.where(id: trait_item).first
        trait_descriptor ? trait_descriptor.trait_name : nil
      end
    end
  end

  def description
    plant_trial_description || ''
  end

  def plant_trial_description
    object.content.plant_trial_description
  end

  def trial_year
    object.content.trial_year
  end

  def country_name
    country_id = object.content.country_id
    return unless country_id.present?
    Country.find(country_id).country_name
  end

  def affiliation
    institute_id || ''
  end

  def institute_id
    object.content.institute_id
  end

  def trial_location_site_name
    object.content.trial_location_site_name
  end

  def place_name
    object.content.place_name
  end

  def latitude
    object.content.latitude
  end

  def longitude
    object.content.longitude
  end

  def altitude
    alt = object.content.altitude
    return unless alt.present?
    "#{alt} m"
  end

  def terrain
    object.content.terrain
  end

  def soil_type
    object.content.soil_type
  end

  def statistical_factors
    object.content.statistical_factors
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

  def layout_url
    if object.submitted_object.try(:layout).present?
      h.plant_trial_path(object.submitted_object)
    end
  end

  def layout_link
    return unless layout_url
    file_name = object.submitted_object.try(:layout).try(:original_filename)
    h.link_to file_name, layout_url
  end

  def raw_data?
    object.content.data_status == 'raw_data'
  end

  def technical_replicate_numbers
    object.content.technical_replicate_numbers.presence || []
  end

  def design_factor_names
    object.content.design_factor_names || []
  end

  def environment
    return unless environment_upload

    upload = SubmissionPlantTrialEnvironmentUploadDecorator.decorate(environment_upload)

    h.content_tag(:pre, upload.parser_summary.join("\n"))
  end

  def treatment
    return unless treatment_upload

    upload = SubmissionPlantTrialTreatmentUploadDecorator.decorate(treatment_upload)

    h.content_tag(:pre, upload.parser_summary.join("\n"))
  end

  def environment_upload
    return @environment_upload if defined?(@environment_upload)
    return unless content.environment_upload_id

    @environment_upload = uploads.plant_trial_environment.find_by(id: content.environment_upload_id)
  end

  def treatment_upload
    return @treatment_upload if defined?(@treatment_upload)
    return unless content.treatment_upload_id

    @treatment_upload = uploads.plant_trial_treatment.find_by(id: content.treatment_upload_id)
  end

  def study_type
    I18n.t(content.study_type, scope: "activerecord.enums.plant_trial.study_type") if content.study_type
  end

  def submission_attributes
    [
      [:plant_trial_name, "Plant trial name", h.data_tables_path(model: :plant_trials, query: { id: submitted_object_id })],
      [:project_descriptor, 'Project'],
      [:species_name, 'Species'],
      [:plant_trial_description, 'Trial description'],
      [:study_type, 'Study type'],
      [:trial_year],
      [:country_name, 'Country'],
      [:institute_id],
      [:trial_location_site_name, 'Site'],
      [:place_name],
      [:latitude],
      [:longitude],
      [:altitude],
      [:terrain],
      [:soil_type],
      [:statistical_factors],
      [:design_factor_names],
      [:layout_link, 'Layout image'],
      [:data_owned_by],
      [:data_provenance],
      [:comments],
      [:doi, 'DOI'],
      [:environment, 'Environment'],
      [:treatment, 'Treatment']
    ]
  end
end
