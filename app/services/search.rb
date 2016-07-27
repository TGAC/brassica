class Search

  attr_accessor :query, :wildcarded_query

  def self.searchables
    return @searchables if defined?(@searchables)
    @searchables = {}.tap do |searchables|
      Searchable.classes.each do |klass|
        searchables[klass.table_name.to_sym] = klass
      end
    end
  end

  def initialize(query)
    query = escape_query_special_chars(query.dup)

    self.query = query
    self.wildcarded_query = add_query_wildcards(query)
  end

  def all
    {}.tap do |all|
      self.class.searchables.keys.each do |table|
        all[table] = results(table)
      end
    end
  end

  def counts
    {}.tap do |counts|
      self.class.searchables.keys.each do |table|
        counts[table] = results(table).count
      end
    end
  end

  def results(table)
    if numeric_query? && numeric_columns?(table)
      filter(table)
    else
      search(table)
    end
  end

  def search(table)
    klass = self.class.searchables[table]
    klass.search(wildcarded_query, size: klass.count)
  end

  def filter(table)
    klass = self.class.searchables[table]

    klass.search(
      filter: {
        or: klass.numeric_columns.map { |column|
          if column.include?(".")
            parts = column.split(".")
            *tables, column = parts
            # NOTE this is only valid for *-1 relationships (not for 1-* or *-*)
            tables = tables.map(&:singularize)
            column = (tables + [column]).join(".")
          end

          { term: { column => query } }
        }
      },
      size: klass.count
    )
  end

  private

  def method_missing(name, *args, &block)
    if self.class.searchables.keys.include?(name.to_sym)
      raise ArgumentError, "No args expected" if args.present?
      results(name.to_sym)
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    self.class.searchables.keys.include?(name.to_sym) or super
  end

  def escape_query_special_chars(query)
    special_chars.each { |chr| query.gsub!(chr, "\\#{chr}") }
    query
  end

  def add_query_wildcards(query)
    query.include?("@") ? query : "*#{query}*"
  end

  def special_chars
    %w(: [ ] ( ) { } + - ~ < = > ^ \\ / && || ! " * ?)
  end

  def numeric_query?
    query =~ /\A-?\d+(\.\d+)?\z/
  end

  def numeric_columns?(table)
    self.class.searchables[table].numeric_columns.present?
  end
end
