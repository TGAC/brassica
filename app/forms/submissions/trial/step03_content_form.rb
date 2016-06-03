module Submissions
  module Trial
    class Step03ContentForm < PlantTrialForm
      property :trait_scores, writeable: false
      property :accessions, writeable: false
      property :upload_id
      property :trait_mapping, writeable: false
      property :replicate_numbers, writeable: false

      def self.permitted_properties
        [
          :upload_id,
          :trait_mapping,
          :replicate_numbers,
          :trait_scores,
          :accessions
        ]
      end

      def upload
        Submission::Upload.trait_scores.where(id: upload_id).first
      end
    end
  end
end
