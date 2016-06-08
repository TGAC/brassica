class SubmissionTraitScoresUploadDecorator < SubmissionUploadDecorator
  def as_json(*)
    super.merge(summary: (parser_summary unless new_record?))
  end

  def parser_summary
    [].tap do |summary|
      summary << 'Uploaded file parsing summary:'
      trait_scores = object.submission.content.step03.trait_scores
      if trait_scores
        histogram = trait_scores.
          group_by{ |id, scores| scores.size }.
          sort{ |score1, score2| score2.first <=> score1.first }

        summary << " - parsed #{trait_scores.size} plant scoring unit(s) with unique identification"
        histogram.each do |scoring_number, plants|
          summary << "  - #{plants.size} unit(s) have #{scoring_number} trait score(s) recorded"
        end
      end

      accessions = object.submission.content.step03.accessions
      lines_or_varieties = submission.content.step03.lines_or_varieties || {}
      new_line_names = []

      if accessions.present?
        unique_accessions = accessions.values.uniq
        old_accessions, new_accessions = split_accessions(unique_accessions)
        lines = Set.new
        varieties = Set.new
        accessions.each do |plant_id, accession|
          next if old_accessions.include? accession
          if lines_or_varieties[plant_id]
            if lines_or_varieties[plant_id]['relation_class_name'] == 'PlantVariety'
              varieties << lines_or_varieties[plant_id]['relation_record_name']
            elsif lines_or_varieties[plant_id]['relation_class_name'] == 'PlantLine'
              lines << lines_or_varieties[plant_id]['relation_record_name']
            end
          end
        end
        old_line_names  = PlantLine.where(plant_line_name: lines.to_a).pluck(:plant_line_name)
        old_lines_count = old_line_names.count
        old_varieties_count  = PlantVariety.count(plant_variety_name: varieties.to_a)
        summary << " - parsed #{unique_accessions.size} different accession(s)"
        summary << "   - out of which, #{old_accessions.count} accession(s) are present in BIP,"
        summary << "   - and #{new_accessions.count} new accession(s) will be created, for which"
        summary << "     - #{old_lines_count} existing plant line(s) will be assigned"
        summary << "     - #{old_varieties_count} existing plant variety(ies) will be assigned,"
        summary << "     - #{varieties.size - old_varieties_count} new plant variety(ies) will be created."

        new_line_names = (lines - old_line_names).to_a
      end

      trait_names = PlantTrialSubmissionDecorator.decorate(object.submission).sorted_trait_names
      trait_mapping = object.submission.content.step03.trait_mapping
      replicate_numbers = object.submission.content.step03.replicate_numbers
      if trait_names && trait_scores
        histogram = trait_scores.
          values.
          map(&:keys).
          flatten.
          group_by{ |col_index| col_index }.
          sort_by(&:first)

        summary << " - parsed scores for #{histogram.size} trait(s), including technical replicates"
        histogram.each do |col_index, scores|
          summary << "  - #{scores.size} score(s) recorded for trait #{trait_names[trait_mapping[col_index]]} rep#{replicate_numbers[col_index]}"
        end
      end

      if new_line_names.present?
        summary << "There were detected #{new_line_names.size} new plant line(s) assigned to new plant accession(s)."
        summary << "This submission cannot be concluded before the following new plant line(s) are successfully submitted, using the Population submission procedure:"
        summary << "  " + new_line_names.join(', ') + "."
      end
    end
  end

  def split_accessions(accessions)
    accessions.partition do |accession|
      PlantAccession.find_by(accession).present?
    end
  end
end
