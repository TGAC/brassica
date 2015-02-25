module Submissions
  class Step02ContentForm < BaseForm
    extend ModelHelper

    property :population_type
    property :plant_line
    property :taxonomy_term

    validates :population_type, inclusion: { in: population_types }
    validates :plant_line, inclusion: { in: plant_lines },
                           if: ->(form) { form.taxonomy_term.blank? }
    validates :taxonomy_term, inclusion: {
                                in: taxonomy_terms,
                                if: ->(form) { form.plant_line.blank? }
                              },
                              absence: {
                                if: ->(form) { form.plant_line.present? }
                              }

  end
end
