module Submissions
  class Step02ContentForm < BaseForm
    extend ModelHelper

    property :population_type

    validates :population_type, inclusion: { in: population_types }
  end
end
