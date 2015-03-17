require "#{Rails.root}/lib/tasks/task_helpers"

namespace :curate do
  task purge_placeholder_records: :environment do
    deleted_records = 0
    dropped_not_nulls = []
    dropped_defaults = []
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
          affected = ActiveRecord::Base.connection.execute(
            "update #{table} set #{column} = NULL where #{column} in #{placeholder_array}"
          ).cmd_tuples
          if affected.to_i > 0
            query("alter table #{table} alter column #{column} drop default")
            puts "    * Removed DEFAULT value for #{table}.#{column}."
            dropped_defaults << "#{table}.#{column}"
          end
        rescue ActiveRecord::StatementInvalid => e
          if e.message.starts_with? 'PG::NotNullViolation'
            query("alter table #{table} alter column #{column} drop not null")
            puts "    * Removed NOT NULL restriction on #{table}.#{column}. Retrying."
            dropped_not_nulls << "#{table}.#{column}"
            retry
          end
        end
      end
    end
    puts "====DELETED #{deleted_records} records."
    if dropped_not_nulls.present?
      puts "====DROPPED NOT NULLS for following columns:"
      puts dropped_not_nulls.sort
    end
    if dropped_defaults.present?
      puts "====DROPPED DEFAULTS for following columns:"
      puts dropped_defaults.sort
    end
  end
end
