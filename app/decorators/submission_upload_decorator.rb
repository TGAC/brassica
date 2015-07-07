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

        summary << " - parsed #{trait_scores.size} plant(s) with unique identification"
        histogram.each do |scoring_number, plants|
          summary << " - #{plants.size} plant(s) have #{scoring_number} trait score(s) recorded"
        end
      end
    end
  end
end
