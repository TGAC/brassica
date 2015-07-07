module Submissions
  module Trial
    class Step03ContentForm < PlantTrialForm
      property :trait_scores, writeable: false
      property :upload_id
      property :trait_mapping, writeable: false

      def self.permitted_properties
        [
          :upload_id,
          :trait_mapping,
          :trait_scores
        ]
      end

      def upload
        Submission::Upload.trait_scores.where(id: upload_id).first
      end
    end
  end
end
