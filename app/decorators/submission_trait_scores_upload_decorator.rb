class SubmissionTraitScoresUploadDecorator < SubmissionUploadDecorator
  def as_json(*)
    super.merge(
      summary: (parser_summary unless new_record?),
      warnings: (parser_warnings unless new_record?)
    )
  end

  def parser_summary
    [].tap do |summary|
      summary << 'Uploaded file parsing summary:'
      if trait_scores
        summary << " - parsed #{trait_scores.size} plant scoring unit(s) with unique identification"
        scoring_per_psu.each do |scoring_number, plants|
          summary << "   - #{plants.size} unit(s) have #{scoring_number} trait score(s) recorded"
        end
      end

      if accessions.present?
        lines, varieties = get_lines_and_varieties
        existing_lines = find_present_plant_lines(lines)
        existing_varieties = find_present_plant_varieties(varieties)
        summary << " - parsed #{unique_accessions.size} different accession(s)"
        summary << "   - out of which, #{existing_accessions.count} accession(s) are present in BIP,"
        summary << "   - and #{new_accessions.count} new accession(s) will be created, for which"
        summary << "     - #{existing_lines.count} existing plant line(s) will be assigned"
        summary << "     - #{existing_varieties.count} existing plant variety(ies) will be assigned,"
        summary << "     - #{varieties.size - existing_varieties.count} new plant variety(ies) will be created."
      end

      summary << " - parsed scores for #{scoring_per_trait.size} trait(s), including technical replicates"
      scoring_per_trait.each do |col_index, scores|
        summary << "   - #{scores.size} score(s) recorded for trait #{trait_names[trait_mapping[col_index]]} rep#{replicate_numbers[col_index]}"
      end

      if new_line_names.present?
        summary << "There were detected #{new_line_names.size} new plant line(s) assigned to new plant accession(s)."
      end
    end
  end

  def parser_warnings
    [].tap do |warnings|
      if new_line_names.present?
        warnings << "This submission cannot be concluded before the following new plant line(s)"
        warnings << "are successfully submitted, using the Population submission procedure:"
        new_line_names.each do |new_line_name|
          warnings << "  - " + new_line_name
        end
      end

      if new_accessions.present?
        invalid_accessions = []

        new_accessions.each do |accession_attrs|
          accession = PlantAccession.new(accession_attrs)

          if accession.invalid? &&
              (accession.errors.key?(:year_produced) ||
               accession.errors.key?(:originating_organisation) ||
               accession.errors.key?(:plant_accession))

            invalid_accessions << accession
          end
        end

        if invalid_accessions.present?
          warnings << "\n" if warnings.present?
          warnings << "This submission cannot be concluded because the following new accessions cannot be created:"
          invalid_accessions.each do |accession|
            warnings << "  - " + accession.plant_accession
          end
        end
      end
    end
  end

  private

  def unique_accessions
    accessions ? accessions.values.uniq : []
  end

  def new_accessions
    split_accessions unless defined?(@new_accessions)
    @new_accessions
  end

  def existing_accessions
    split_accessions unless defined?(@existing_accessions)
    @existing_accessions
  end

  def split_accessions
    @existing_accessions, @new_accessions = unique_accessions.partition do |accession|
      present_accession?(accession)
    end
  end

  def present_accession?(accession)
    PlantAccession.find_by(accession).present?
  end

  def new_line_names
    lines = get_lines_and_varieties.first
    existing_lines = find_present_plant_lines(lines)
    (lines - existing_lines.map(&:plant_line_name)).to_a
  end

  def find_present_plant_lines(line_names)
    PlantLine.where(plant_line_name: line_names.to_a)
  end

  def find_present_plant_varieties(variety_names)
    PlantVariety.where(plant_variety_name: variety_names.to_a)
  end

  def get_lines_and_varieties
    lines = Set.new
    varieties = Set.new
    (accessions || []).each do |plant_id, accession|
      next if present_accession?(accession)
      if lines_or_varieties[plant_id]
        if lines_or_varieties[plant_id]['relation_class_name'] == 'PlantVariety'
          varieties << lines_or_varieties[plant_id]['relation_record_name']
        elsif lines_or_varieties[plant_id]['relation_class_name'] == 'PlantLine'
          lines << lines_or_varieties[plant_id]['relation_record_name']
        end
      end
    end
    [lines, varieties]
  end

  def scoring_per_psu
    trait_scores.
      group_by{ |_,scores| scores.size }.
      sort{ |score1,score2| score2.first <=> score1.first }
  end

  def scoring_per_trait
    if trait_names && trait_scores
      trait_scores.
        values.
        map(&:keys).
        flatten.
        group_by{ |col_index| col_index }.
        sort_by(&:first)
    else
      {}
    end
  end

  def accessions
    object.submission.content.step04.accessions
  end

  def lines_or_varieties
    submission.content.step04.lines_or_varieties || {}
  end

  def trait_names
    PlantTrialSubmissionDecorator.decorate(object.submission).sorted_trait_names
  end

  def trait_mapping
    object.submission.content.step04.trait_mapping
  end

  def replicate_numbers
    object.submission.content.step04.replicate_numbers
  end

  def trait_scores
    object.submission.content.step04.trait_scores || {}
  end
end
