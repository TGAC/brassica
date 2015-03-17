require "#{Rails.root}/lib/tasks/task_helpers"

namespace :curate do
  task purge_empty_tables: :environment do
    tables_to_remove = []
    all_tables.each do |table|
      pkey_name = pkey_names(table)[0]

      pkey_values = simple_query("select distinct(#{pkey_name}) from #{table}")

      if pkey_values.all?{ |v| meaningless?(v) }
        puts "#{table}.#{pkey_name}: #{pkey_values}. Candidate to be removed."
        ActiveRecord::Base.connection.execute("drop table if exists #{table}")
        tables_to_remove << table
      end
    end
    if tables_to_remove.present?
      puts "====DROPPED #{tables_to_remove.size} tables:"
      puts tables_to_remove.join(',')
    else
      puts '====DROPPED 0 tables.'
    end
  end
end
