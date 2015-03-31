# This file aggregates helper methods which are used in various migrations
module MigrationHelper

  # Escapes a string literal so that it can be safely fed into PGSQL queries
  # NOTE: with literals of this type prefix the string delimiters with E, e.g.:
  # SELECT * FROM plant_populations WHERE plant_population_name = E'#{escaped_name}';
  # (Because SQL standards are for losers... ;)
  def escape(string)
    if string.nil?
      nil
    else
      pattern = /(\'|\"|\.|\*|\/|\-|\\|\)|\$|\+|\(|\^|\?|\!|\~|\`)/
      string.gsub(pattern){|match|"\\"  + match}
    end
  end

  # Retrieves the ID value corresponding to the given column.
  # Assumes column_name is string and unique
  def get_id_for_value(table_name, column_name, column_value)
    silence_stream(STDOUT) do
      if column_value.blank?
        return nil
      end

      result = execute "SELECT id FROM #{table_name} WHERE #{column_name} = \
        E'#{escape(column_value)}'"

      if result.ntuples == 0
        return nil
      else
        result.first['id']
      end
    end
  end


  # This sets the 'foreign_key' field in a given table to a specific value
  # for records which match 'column_name' = 'column_value'
  # Assumes column_name is string and unique
  def set_fk_for_value(table_name, column_name, column_value, foreign_key, id)
    update = "UPDATE #{table_name} \
          SET #{foreign_key} = #{id} \
          WHERE #{column_name} = E'#{escape(column_value)}'"
    execute(update)
  end

  # Replaces the foreign key in the selected table with an ID-based one
  def replace_fk(source_table_name, target_table_name, existing_fk,
    new_fk, target_pkey_name)

    puts "Attempting to replace FK #{existing_fk} with #{new_fk} in table #{source_table_name}..."

    unless column_exists?(source_table_name, new_fk)
      add_column source_table_name, new_fk, :int

      # Create indices on existing FKs to speed up the assignment
      upsert_index(source_table_name, existing_fk)
      upsert_index(target_table_name, existing_fk)

      errors = 0
      counter = 0

      records = execute("SELECT * FROM #{source_table_name}")
      records.each do |record|
        tgt_id = get_id_for_value(target_table_name, target_pkey_name, record[existing_fk])

        if tgt_id.blank?
          errors += 1
        else
          silence_stream(STDOUT) do
            set_fk_for_value(source_table_name, existing_fk, record[existing_fk],
                           new_fk, tgt_id)
          end
        end

        counter += 1
        if counter % 1000 == 0
          puts "Processed #{counter.to_s} records from #{source_table_name}..."
        end

      end

      if errors == 0
        puts "No errors detected - removing old FK #{existing_fk}"
        remove_column source_table_name, existing_fk
      else
        puts "Found #{errors.to_s} mismatched records - keeping old FK #{existing_fk} in #{source_table_name}"
      end
    else
      puts "...table #{source_table_name} already contains column #{new_fk}. Skipping."
    end
  end

  # Upserts an index on the target field
  def upsert_index(table_name, column_name)
    puts "Attempting to index column #{column_name} in #{table_name}..."

    idx_name = "#{table_name}_#{column_name}_idx"

    result = execute("SELECT relname FROM pg_class \
      WHERE relname = '#{idx_name}'").collect{|r| r['relname']}

    if result.include? "#{table_name}_#{column_name}_idx"
      puts "...table #{table_name} alredy contains an index on #{column_name}. Skipping."
    else
      execute("CREATE INDEX #{table_name}_#{column_name}_idx ON \
              #{table_name} (#{column_name})")
      puts "...successfully added index on column #{column_name} in #{table_name}."
    end
  end


end