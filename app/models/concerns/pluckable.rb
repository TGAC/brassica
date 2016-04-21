# Single Concern for all models to pluck columns for data tables
# Define columns to be plucked by reloading:
#
#  - self.table_columns: columns visible to the end user
#  - self.ref_columns: columns not visible to the end user, esp. references
#
# Columns should be defined in an array like that:
# [
#   'plant_line_name',
#   'taxonomy_terms.name'
# ]
module Pluckable extend ActiveSupport::Concern
  included do
    include Joinable

    def self.pluck_columns(uid = nil)
      query = self.all
      # Detect Relatable models
      count_columns = if self.respond_to?(:privacy_adjusted_count_columns)
                        query = join_counters(query, uid)
                        privacy_adjusted_count_columns
                      else
                        []
                      end
      columns = table_columns + count_columns + ref_columns
      query = join_columns(columns, query, true)
      query.pluck(*columns)
    end

    def self.table_columns; [] end
    def self.ref_columns; [] end
  end
end
