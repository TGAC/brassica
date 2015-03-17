namespace :curate do
  def all_tables
    simple_query('select relname from pg_stat_user_tables')
    # NOTE alternative?
    # simple_query(
    #   "select table_name from information_schema.tables where table_schema = 'public'"
    # )
  end

  def column_names(table)
    simple_query(
      "select column_name
       from information_schema.columns
       where table_name = '#{table}'
       and data_type = 'text'"
    )
  end

  def pkey_names(table)
    simple_query(
      "SELECT a.attname FROM   pg_index i
       JOIN   pg_attribute a ON a.attrelid = i.indrelid
       AND    a.attnum = ANY(i.indkey)
       WHERE  i.indrelid = '#{table}'::regclass
       AND    i.indisprimary"
    )
  end

  def tables_with_column(column)
    simple_query(
      "select table_name
       from information_schema.columns
       where column_name = '#{column}'
       and data_type = 'text'"
    ) - %w(foreign_data_wrappers column_domain_usage)
  end

  # Use for one column select query only
  def simple_query(query)
    query(query).flatten
  end

  def query(query)
    ActiveRecord::Base.connection.execute(query).values
  end

  def meaningless?(value)
    value && blank_records.include?(value)
  end

  def blank_records
    ['unspecified', '', 'not applicable', 'none','xxx','n/a','ooo']
  end
end
