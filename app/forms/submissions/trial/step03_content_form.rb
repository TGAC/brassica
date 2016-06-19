module Submissions
  module Trial
    class Step03ContentForm < PlantTrialForm
      property :lines_or_varieties
      collection :technical_replicate_numbers
      collection :design_factor_names

      validates :lines_or_varieties, inclusion: { in: %w(plant_lines plant_varieties) }

      validate do
        all_valid = technical_replicate_numbers.all? do |number|
          number.to_i.to_s == number && number.to_i > 0
        end
        errors.add(:technical_replicate_numbers, :invalid) unless all_valid
      end

      def technical_replicate_numbers
        super || []
      end

      def design_factor_names
        super || []
      end
    end
  end
end
