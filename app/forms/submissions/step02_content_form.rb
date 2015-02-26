module Submissions
  class Step02ContentForm < BaseForm
    extend ModelHelper

    property :population_type
    property :plant_line
    property :taxonomy_term

    property :plant_line_name
    property :plant_line_comments
    property :plant_line_data_provenance

    validates :population_type, inclusion: { in: population_types }
    validates :plant_line, inclusion: { in: plant_lines, allow_blank: true }
    validates :taxonomy_term, inclusion: { in: taxonomy_terms, allow_blank: true }

    validate do |form|
      if input_missing?
        errors.add(:plant_line, " / Taxonomy term is required")
      end
    end

    def input_missing?
      !plant_line_selected? && !plant_line_added? && !taxonomy_term_selected?
    end

    def plant_line_selected?
      plant_line.present?
    end

    def taxonomy_term_selected?
      taxonomy_term.present?
    end

    def plant_line_added?
      added_plant_line_attributes.all? { |attr| send(attr).present? }
    end

    def added_plant_line_attributes
      [:plant_line_name, :plant_line_comments, :plant_line_data_provenance]
    end
  end
end
