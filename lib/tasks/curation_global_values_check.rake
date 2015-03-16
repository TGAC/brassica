namespace :curate do
  task global_values_check: :environment do
    column = 'data_status'

    tables = tables_with_column(column)

    tables.each do |table|
      result = simple_query("select distinct(#{column}) from #{table}")
      puts "For table #{table}: #{result}"
    end
  end


  task find_pkey_values: :environment do
    tables = simple_query('select relname from pg_stat_user_tables')
    tables -= ['schema_migrations', 'users', 'submissions', 'taxonomy_term']
    tables_to_remove = []

    tables.each do |table|
      pkey_name = simple_query(
        "SELECT a.attname FROM   pg_index i
         JOIN   pg_attribute a ON a.attrelid = i.indrelid
         AND    a.attnum = ANY(i.indkey)
         WHERE  i.indrelid = '#{table}'::regclass
         AND    i.indisprimary"
      )[0]

      pkey_values = simple_query("select distinct(#{pkey_name}) from #{table}")

      if pkey_values.all?{ |v| meaningless?(v) }
        puts "#{table}.#{pkey_name}: #{pkey_values}. Candidate to be removed."
        ActiveRecord::Base.connection.execute("drop table if exists #{table}")
        tables_to_remove << table
      end
    end
    if tables_to_remove.present?
      puts '====DROPPED tables:'
      puts tables_to_remove.join(',')
    end
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
