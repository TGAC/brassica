require "#{Rails.root}/lib/tasks/task_helpers"

namespace :curate do
  task purge_empty_columns: :environment do
    all_tables.each do |table|
      columns = simple_query(
        "select column_name from information_schema.columns where table_name = '#{table}'"
      )

      puts "- Table #{table}:"
      columns.each do |column|
        values = simple_query("select distinct(#{column}) from #{table}")
        if values.all?{ |v| meaningless?(v) }
          puts "  * Column #{column} has only meaningless values: #{values}. Dropping."
          ActiveRecord::Base.connection.execute(
            "alter table #{table} drop column if exists #{column}"
          )
        end
      end
    end
  end
end
