class SubmissionUploadDecorator < Draper::Decorator
  delegate_all

  def as_json(*)
    super.merge(
      delete_url: Rails.application.routes.url_helpers.
        submission_upload_path(object.submission, object),
      logs: object.logs,
      errors: object.errors[:file],
      summary: parser_summary
    )
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
      if accessions
        unique_accessions = accessions.values.uniq
        summary << " - parsed #{unique_accessions.size} different accession(s)"
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
    end
  end
end
