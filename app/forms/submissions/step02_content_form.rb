module Submissions
  class Step02ContentForm < BaseForm
    extend ModelHelper

    property :population_type
    property :taxonomy_term

    validates :population_type, inclusion: { in: population_types }
    validates :taxonomy_term, inclusion: { in: TaxonomyTerm.names }
  end
end
