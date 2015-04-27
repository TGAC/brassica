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
    def self.pluck_columns
      query = self.all
      cc = respond_to?(:count_columns) ? count_columns : []
      columns = table_columns + cc + ref_columns
      columns.each do |column|
        relation = column.to_s.split('.')[0].pluralize if column.to_s.include? '.'
        next unless relation && relation != self.table_name
        relation = relation.singularize unless reflections.keys.include?(relation)
        next unless reflections.keys.include?(relation)
        query = query.includes(relation.to_sym)
      end
      query.pluck(*columns)
    end

    def self.table_columns; [] end
    def self.ref_columns; [] end
  end
end
