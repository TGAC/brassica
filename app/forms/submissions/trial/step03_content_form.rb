module Submissions
  module Trial
    class Step03ContentForm < PlantTrialForm
      property :trait_score_list
      property :upload_id
      property :trait_mapping

      # plant_scoring_unit ???
      # trait_descriptor ???

      collection :new_trait_scores do
        property :score_value

        validates :score_value, presence: true
      end

      def self.permitted_properties
        [
          :upload_id,
          :trait_mapping,
          {
            :trait_score_list => [],
            :new_trait_scores => [
              :score_value
            ]
          }
        ]
      end

      def trait_score_list
        super.try { |tsl| tsl.select(&:present?) }
      end

      def new_trait_scores
        super || []
      end

      def upload
        Submission::Upload.trait_scores.where(id: upload_id).first
      end
    end
  end
end
