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
      columns = columns.map do |column|
        if column.to_s.split('.').length == 3
          from, to, field = column.to_s.split('.')
          from = from.singularize unless reflections.keys.include?(relation)
          to = to.singularize unless reflections.keys.include?(relation)
          query = query.includes(from.to_sym => to.to_sym)
          column.to_s.split('.')[1..-1].join('.')
        elsif column.to_s.include? '.'
          relation = column.to_s.split('.')[0].pluralize
          relation = relation.singularize unless reflections.keys.include?(relation)
          query = query.includes(relation.to_sym)
          column
        else
          column
        end
      end
      query.pluck(*columns)
    end
  end
end
