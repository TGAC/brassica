module Submissions
  module Trial
    class Step03ContentForm < PlantTrialForm
      property :trait_scores, writeable: false
      property :accessions, writeable: false
      property :upload_id
      property :trait_mapping, writeable: false
      property :replicate_numbers, writeable: false
      property :design_factors, writeable: false
      property :design_factor_names, writeable: false

      def self.permitted_properties
        [
          :upload_id,
          :trait_mapping,
          :replicate_numbers,
          :trait_scores,
          :design_factors,
          :design_factor_names,
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
