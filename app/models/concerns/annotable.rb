# Single Concern for all models that have at least that set of fields:
# t.text "comments"
# t.text "entered_by_whom"
# t.text "data_provenance"
#
# and could have one or two more optional fields
# t.date "date_entered"
# t.text "data_owned_by"
#
# Provides common methods for dealing with these fields.
# Should be included LAST since it redefines ref_columns field,
# that is also important for e.g. Pluckable
module Annotable extend ActiveSupport::Concern
  included do
    def annotations_as_json
      as_json(
        only: [
          :comments, :entered_by_whom, :data_provenance
        ] +
        (has_attribute?(:date_entered) ? [:date_entered] : []) +
        (has_attribute?(:data_owned_by) ? [:data_owned_by] : []) +
        (has_attribute?(:pubmed_id) ? [:pubmed_id] : [])
      )
    end

    @old_ref_columns = (self.respond_to?(:ref_columns) ? ref_columns : [])

    def self.ref_columns
      @old_ref_columns + ["#{table_name}.id"]
    end
  end
end
