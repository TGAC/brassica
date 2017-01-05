class SubmissionTraitScoresUploadDecorator < SubmissionUploadDecorator
  def as_json(*)
    super.merge(
      summary: (parser_summary unless new_record?),
      warnings: (parser_warnings unless new_record?)
    )
  end

  def parser_summary
    [].tap do |summary|
      p 'XXXXXXXXXXXXXX'
      summary << 'Uploaded file parsing summary:'
      if plant_lines
        summary << " - parsed #{plant_lines.size} plant line(s) with unique names"
      end

      # if accessions.present?
      #   existing_accessions, new_accessions = split_accessions
      #   lines, varieties = get_lines_and_varieties
      #   existing_lines = find_present_plant_lines(lines)
      #   existing_varieties = find_present_plant_varieties(varieties)
      #   summary << " - parsed #{unique_accessions.size} different accession(s)"
      #   summary << "   - out of which, #{existing_accessions.count} accession(s) are present in BIP,"
      #   summary << "   - and #{new_accessions.count} new accession(s) will be created, for which"
      #   summary << "     - #{existing_lines.count} existing plant line(s) will be assigned"
      #   summary << "     - #{existing_varieties.count} existing plant variety(ies) will be assigned,"
      #   summary << "     - #{varieties.size - existing_varieties.count} new plant variety(ies) will be created."
      # end
      #
      # summary << " - parsed scores for #{scoring_per_trait.size} trait(s), including technical replicates"
      # scoring_per_trait.each do |col_index, scores|
      #   summary << "   - #{scores.size} score(s) recorded for trait #{trait_names[trait_mapping[col_index]]} rep#{replicate_numbers[col_index]}"
      # end
      #
      # if new_line_names.present?
      #   summary << "There were detected #{new_line_names.size} new plant line(s) assigned to new plant accession(s)."
      # end
    end
  end

  def parser_warnings
    [].tap do |warnings|
      # if new_line_names.present?
      #   warnings << "This submission cannot be concluded before the following new plant line(s)"
      #   warnings << "are successfully submitted, using the Population submission procedure:"
      #   new_line_names.each do |new_line_name|
      #     warnings << "  - " + new_line_name
      #   end
      # end
    end
  end

  private

  # def find_present_plant_varieties(variety_names)
  #   PlantVariety.where(plant_variety_name: variety_names.to_a)
  # end
  #
  # def get_lines_and_varieties
  #   lines = Set.new
  #   varieties = Set.new
  #   (accessions || []).each do |plant_id, accession|
  #     next if present_accession?(accession)
  #     if lines_or_varieties[plant_id]
  #       if lines_or_varieties[plant_id]['relation_class_name'] == 'PlantVariety'
  #         varieties << lines_or_varieties[plant_id]['relation_record_name']
  #       elsif lines_or_varieties[plant_id]['relation_class_name'] == 'PlantLine'
  #         lines << lines_or_varieties[plant_id]['relation_record_name']
  #       end
  #     end
  #   end
  #   [lines, varieties]
  # end
end
