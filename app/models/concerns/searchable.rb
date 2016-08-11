# Include for every model that should be indexed by ElasticSearch
# IMPORTANT! Please redefine self.indexed_json_structure in your
# model class if table_columns:
#   - include aliasing (... AS ...)
#   - refer to relations deeper than one level
module Searchable extend ActiveSupport::Concern
  included do
    include Elasticsearch::Model

    index_name ['brassica', Rails.env, base_class.name.underscore.pluralize].join("_")

    after_commit(on: :create) do
      __elasticsearch__.index_document if published?
    end

    after_commit(on: :update) do
      if !published? && __elasticsearch__.client.exists(id: id, index: self.class.index_name)
        __elasticsearch__.delete_document
      elsif __elasticsearch__.client.exists(id: id, index: self.class.index_name)
        __elasticsearch__.update_document
      else
        __elasticsearch__.index_document
      end
    end

    after_commit(on: :destroy) do
      __elasticsearch__.delete_document if published?
    end

    after_touch { __elasticsearch__.index_document if published? }

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
    ActiveRecord::Base.descendants.select do |klass|
      klass.ancestors.include?(Searchable)
    end
  end
end
