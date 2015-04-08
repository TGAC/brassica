# Single Concern for all models to pluck certain columns for data tables
# Pass columns in table like that:
# [
#   'plant_line_name',
#   'taxonomy_terms.name'
# ]
module Pluckable extend ActiveSupport::Concern
  included do
    def self.pluck_columns(columns)
      query = self.all
      columns.each do |column|
        relation = column.to_s.split('.')[0].pluralize if column.to_s.include? '.'
        next unless relation
        relation = relation.singularize unless reflections.keys.include?(relation)
        query = query.includes(relation.to_sym)
      end
      query.pluck(*columns)
    end
  end
end
