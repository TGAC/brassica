require "#{Rails.root}/lib/tasks/task_helpers"

namespace :curate do
  task purge_empty_columns: :environment do
    dropped_columns = []
    all_tables.each do |table|
      puts "- Table #{table}:"
      column_names(table).each do |column|
        values = simple_query("select distinct(#{column}) from #{table}")
        if values.all?{ |v| meaningless?(v) }
          puts "  * Column #{column} has only meaningless values: #{values}. Dropping."
          query("alter table #{table} drop column if exists #{column}")
          dropped_columns << "#{table}.#{column}"
        end
      end
    end
    if dropped_columns.present?
      puts "====DROPPED #{dropped_columns.size} columns:"
      puts dropped_columns.sort
    else
      puts '====DROPPED 0 columns.'
    end
  end
end
