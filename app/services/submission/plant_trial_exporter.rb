class Submission::PlantTrialExporter < Submission::Exporter
  def documents
    {
      plant_trial: plant_trial,
      trait_descriptors: trait_descriptors,
      trait_scoring: trait_scoring
    }.reject { |_,v| v.nil? }
  end

  private

  def plant_trial
    generate_document PlantTrial,
                      { id: submitted_object.id },
                      column_names: PlantTrial.table_columns[0..-3]
  end

  def trait_descriptors
    generate_document TraitDescriptor,
                      { id: submitted_object.trait_descriptors.map(&:id) }
  end

  def trait_scoring
    data = submitted_object.scoring_table_data(user_id: @submission.user.id, extended: true)
    return nil if data.empty?
    CSV.generate(headers: true) do |csv|
      csv << [
        I18n.t('tables.plant_scoring_units.scoring_unit_name'),
        I18n.t('tables.plant_accessions.plant_accession'),
        I18n.t('tables.plant_lines.plant_line_name'),
        I18n.t('tables.plant_varieties.plant_variety_name'),
        I18n.t('tables.plant_accessions.plant_accession_derivation'),
        I18n.t('tables.plant_accessions.originating_organisation'),
        I18n.t('tables.plant_accessions.year_produced'),
        I18n.t('tables.plant_accessions.date_harvested'),
        I18n.t('tables.plant_scoring_units.number_units_scored'),
        I18n.t('tables.plant_scoring_units.scoring_unit_sample_size'),
        I18n.t('tables.plant_scoring_units.scoring_unit_frame_size'),
        I18n.t('tables.design_factors.design_factors'),
        I18n.t('tables.plant_scoring_units.date_planted')
      ] + submitted_object.decorate.trait_headers
      data.each { |row| csv << row[0...-1] }  # Drop the BIP internal id
    end
  end
end
