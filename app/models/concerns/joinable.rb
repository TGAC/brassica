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
            subqueries = query.joins_values.select{|v| v.class == Squeel::Nodes::SubqueryJoin}
            symbols = subqueries.collect{ |s| s.subquery.right }
            query = query.joins(relation.to_sym) unless symbols.include? relation.pluralize
          end
        end
        query
      end
    end
  end
end
