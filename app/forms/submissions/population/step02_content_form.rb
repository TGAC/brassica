module Submissions
  module Population
    class Step02ContentForm < PlantPopulationForm
      property :taxonomy_term
      property :female_parent_line
      property :male_parent_line

      validates :female_parent_line, :male_parent_line, inclusion: {
        in: :plant_line_names,
        allow_blank: true
      }

      def plant_line_names
        PlantLine.pluck(:plant_line_name)
      end
    end
  end
end
