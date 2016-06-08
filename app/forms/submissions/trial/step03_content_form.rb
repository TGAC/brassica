module Submissions
  module Trial
    class Step03ContentForm < PlantTrialForm
      property :trait_scores, writeable: false
      property :accessions, writeable: false
      property :upload_id
      property :trait_mapping, writeable: false

      def self.permitted_properties
        [
          :upload_id,
          :trait_mapping,
          :trait_scores,
          :accessions
        ]
      end

      def upload
        upload = Submission::Upload.trait_scores.find_by(id: upload_id)
        SubmissionTraitScoresUploadDecorator.decorate(upload) if upload
      end
    end
  end
end
