module Submissions
  module Trial
    class Step03ContentForm < PlantTrialForm
      property :trait_mapping, writeable: false
      property :trait_scores, writeable: false
      property :accessions, writeable: false
      property :lines_or_varieties, writeable: false
      property :replicate_numbers, writeable: false
      property :design_factor_names, writeable: false
      property :design_factors, writeable: false
      property :upload_id

      def self.permitted_properties
        [
          :trait_mapping,
          :trait_scores,
          :accessions,
          :lines_or_varieties,
          :replicate_numbers,
          :design_factor_names,
          :design_factors,
          :upload_id
        ]
      end

      def upload
        upload = Submission::Upload.trait_scores.find_by(id: upload_id)
        SubmissionTraitScoresUploadDecorator.decorate(upload) if upload
      end
    end
  end
end
