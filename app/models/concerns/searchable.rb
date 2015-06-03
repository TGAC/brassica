# Include for every model that should be indexed by ElasticSearch
# IMPORTANT! Please redefine self.indexed_json_structure in your
# model class if table_columns:
#   - include aliasing (... AS ...)
#   - refer to relations deeper than one level
module Searchable extend ActiveSupport::Concern
  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    index_name ['brassica', Rails.env, base_class.name.underscore.pluralize].join("_")

    after_touch { __elasticsearch__.index_document }

    def self.numeric_columns
      []
    end

    def self.indexed_json_structure
      return @indexed_json_structure if @indexed_json_structure
      only = table_columns.select{ |c| !c.include? '.' }.map(&:to_sym)
      to_include = {}
      table_columns.select{ |c| c.include? '.' }.each do |c|
        table, column = c.split('.')
        to_include[table.singularize.to_sym] = { only: [column.to_sym] }
      end
      @indexed_json_structure = {
        only: only,
        include: to_include
      }
    end

    def as_indexed_json(options = {})
      as_json(self.class.indexed_json_structure)
    end
  end

  def self.classes
    ActiveRecord::Base.descendants.select { |klass|
      klass.ancestors.include?(Searchable)
    }
  end
end
