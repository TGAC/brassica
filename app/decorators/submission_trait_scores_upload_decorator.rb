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

        summary << " - parsed #{trait_scores.size} plant(s) with unique identification"
        histogram.each do |scoring_number, plants|
          summary << "  - #{plants.size} plant(s) have #{scoring_number} trait score(s) recorded"
        end
      end

      trait_names = PlantTrialSubmissionDecorator.decorate(object.submission).sorted_trait_names
      trait_mapping = object.submission.content.step03.trait_mapping
      if trait_names && trait_scores
        histogram = trait_scores.
          values.
          map(&:keys).
          flatten.
          group_by{ |col_index| col_index }.
          sort_by(&:first)

        summary << " - parsed scores for #{histogram.size} trait(s)"
        histogram.each do |col_index, scores|
          next unless trait_mapping[col_index]
          summary << "  - #{scores.size} score(s) recorded for trait #{trait_names[trait_mapping[col_index]]}"
        end
      end
    end
  end
end
