module Submissions
  module Trial
    class Step03ContentForm < PlantTrialForm
      property :trait_score_list

      # plant_scoring_unit ???
      # trait_descriptor ???

      collection :new_trait_scores do
        property :score_value

        validates :score_value, presence: true
      end

      def self.permitted_properties
        [
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
    end
  end
end
