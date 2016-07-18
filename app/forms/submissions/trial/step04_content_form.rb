module Submissions
  module Trial
    class Step04ContentForm < PlantTrialForm
      property :upload_id

      def upload
        upload = Submission::Upload.trait_scores.find_by(id: upload_id)
        SubmissionTraitScoresUploadDecorator.decorate(upload) if upload
      end
    end
  end
end
