require "#{Rails.root}/lib/tasks/task_helpers"

namespace :curate do
  task find_nas: :environment do
    value_to_check = 'n/a'

    all_tables.each do |table|
      puts "Dealing with table #{table}"
      query("select * from #{table}").each do |record|
        record.each_with_index do |column, i|
          if column == value_to_check
            puts "   FOUND #{value_to_check} in #{table} in column #{i}"
          end
        end
      end
    end
  end

  task purge_placeholder_records: :environment do
    deleted_records = 0
    dropped_not_nulls = []
    dropped_defaults = []

    # Stage 0: preparation for two special cases
    query('alter table map_positions drop constraint idx_143597_primary')
    query('alter table map_positions add constraint idx_143597_primary primary key(linkage_group_id, mapping_locus)')
    query('alter table map_locus_hits drop constraint idx_143575_primary')
    query('alter table map_locus_hits add constraint idx_143575_primary primary key(linkage_group_id, mapping_locus)')

    blank_array = '(' + blank_records.map{ |br| "'#{br}'" }.join(',') + ')'
    all_tables.each do |table|
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
          elsif e.message.starts_with? 'PG::InvalidTableDefinition'
            query("alter table #{table} alter column #{column} drop not null")
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
