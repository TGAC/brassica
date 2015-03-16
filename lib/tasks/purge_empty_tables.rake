namespace :curate do
  task purge_empty_tables: :environment do
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
end
