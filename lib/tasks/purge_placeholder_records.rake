require "#{Rails.root}/lib/tasks/task_helpers"

namespace :curate do
  task purge_placeholder_records: :environment do
    deleted_records = 0
    blank_array = '(' + blank_records.map{ |br| "'#{br}'" }.join(',') + ')'
    (all_tables - ['map_locus_hits','map_positions']).each do |table|
      puts "- Table #{table} PKeys: #{pkey_names(table)}"
      query =
        "select * from #{table} where " +
        pkey_names(table).map{ |pk| "#{pk} in #{blank_array}" }.join(' and ')

      puts "  * #{query}:"
      query(query).each do |record|
        puts "    * #{record}"
        query(query.gsub('select *','delete'))
        deleted_records += 1
      end

      puts "  * NULLifying all blank references in #{table}."
      placeholder_array = "('unspecified','not applicable','none')" # Leave '' intact
      column_names(table).each do |column|
        begin
          query("update #{table} set #{column} = NULL where #{column} in #{placeholder_array}")
        rescue ActiveRecord::StatementInvalid => e
          if e.message.starts_with? 'PG::NotNullViolation'
            query("alter table #{table} alter column #{column} drop not null")
            puts "    * Removed NOT NULL restriction on #{table}.#{column}. Retrying."
            retry
          end
        end
      end
    end
    puts "====DELETED #{deleted_records} records."
  end
end
