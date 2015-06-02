module Submissions
  class Step02ContentForm < BaseForm
    extend ModelHelper

    property :population_type
    property :taxonomy_term

    validates :taxonomy_term, inclusion: { in: TaxonomyTerm.names, message: I18n.t('submission.errors.taxonomy_term_missing') }
    validates :population_type, inclusion: { in: population_types, message: I18n.t('submission.errors.population_type_missing') }
  end
end
