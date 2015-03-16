namespace :curate do
  def all_tables
    simple_query('select relname from pg_stat_user_tables')
    # NOTE alternative?
    # simple_query(
    #   "select table_name from information_schema.tables where table_schema = 'public'"
    # )
  end

  def tables_with_column(column)
    simple_query(
      "select table_name
       from information_schema.columns
       where column_name = '#{column}'"
    ) - %w(foreign_data_wrappers column_domain_usage)
  end

  # Use for one column select query only
  def simple_query(query)
    ActiveRecord::Base.connection.execute(query).values.flatten
  end

  def meaningless?(value)
    blank_records = ['unspecified', '', 'not applicable', 'none']
    value && blank_records.include?(value)
  end
end
