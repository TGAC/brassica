module Submissions
  class Step02ContentForm < BaseForm
    extend ModelHelper

    property :population_type
    property :taxonomy_term

    validates :taxonomy_term, inclusion: { in: TaxonomyTerm.names, message: 'Please select a taxonomy term from the list.' }
    validates :population_type, inclusion: { in: population_types, message: 'Please select a population type from the list.' }
  end
end
