# Provides generic joining capability for other concerns
module Joinable
  def self.included(base)
    base.class_eval do
      def self.join_columns(columns, query, include = false)
        columns.each do |column|
          relation = column.to_s.split('.')[0].pluralize if column.to_s.include? '.'
          next unless relation && relation != self.table_name
          relation = relation.singularize unless reflections.keys.include?(relation)
          next unless reflections.keys.include?(relation)
          if include
            query = query.includes(relation.to_sym)
          else
            join_tables = query.joins_values.select { |v| v.is_a?(Symbol) }.map(&:to_s)

            # TODO: what about other joins? it probably should handle handwritten inner joins too
            join_subqueries = query.joins_values.select { |v| v.to_s.starts_with?("LEFT OUTER JOIN") }

            join_tables = join_tables + join_subqueries.map do |v|
              v.match(/LEFT OUTER JOIN \(.*\) (.*) ON/).try(:[], 1)
            end.compact

            query = query.joins(relation.to_sym) unless join_tables.include?(relation.pluralize)
          end
        end
        query
      end
    end
  end
end
