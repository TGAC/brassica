module Submissions
  module Trial
    class Step04ContentForm < PlantTrialForm
      property :trait_mapping
      property :trait_scores
      property :accessions
      property :lines_or_varieties
      property :replicate_numbers
      property :design_factor_names
      property :design_factors
      property :upload_id

      def upload
        upload = Submission::Upload.trait_scores.find_by(id: upload_id)
        SubmissionTraitScoresUploadDecorator.decorate(upload) if upload
      end
    end
  end
end
