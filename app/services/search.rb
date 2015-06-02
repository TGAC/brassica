class Search

  attr_accessor :query, :wildcarded_query

  def self.searchable_klasses
    @searchable_klasses ||= ActiveRecord::Base.descendants.select { |klass|
      klass.ancestors.include?(Searchable)
    }
  end

  def self.searchable_tables
    @searchable_tables ||= searchable_klasses.map(&:table_name)
  end

  def initialize(query)
    query = escape_query_special_chars(query.dup)

    self.query = query
    self.wildcarded_query = add_query_wildcards(query)
  end

  def all
    {}.tap do |all|
      self.class.searchable_tables.each do |table|
        all[table.to_sym] = results(table)
      end
    end
  end

  def counts
    {}.tap do |counts|
      self.class.searchable_tables.each do |table|
        counts[table.to_sym] = results(table).count
      end
    end
  end

  def results(table)
    if numeric_query? && table.classify.constantize.numeric_columns.present?
      filter(table)
    else
      search(table)
    end
  end

  def search(table)
    klass = table.classify.constantize
    klass.search(wildcarded_query, size: klass.count)
  end

  def filter(table)
    klass = table.classify.constantize

    klass.search(
      filter: {
        or: klass.numeric_columns.map { |column|
          if column.include?(".")
            parts = column.split(".")
            *tables, column = parts
            tables = tables.map(&:singularize)
            column = (tables | [column]).join(".")
          end

          { term: { column => query } }
        }
      },
      size: klass.count
    )
  end

  private

  def method_missing(name, *args, &block)
    if self.class.searchable_tables.include?(name.to_s)
      raise ArgumentError, "No args expected" if args.present?
      results(name.to_s)
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    self.class.searchable_tables.include?(name.to_s) or super
  end

  def escape_query_special_chars(query)
    special_chars.each { |chr| query.gsub!(chr, "\\#{chr}") }
    query
  end

  def add_query_wildcards(query)
    query.include?("@") ? query : "*#{query}*"
  end

  def special_chars
    %w(: [ ] ( ) { } + - ~ < = > ^ \ / && || ! " * ?)
  end

  def numeric_query?
    query =~ /\A-?\d+(\.\d+)?\z/
  end

end
