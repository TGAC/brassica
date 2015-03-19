namespace :curate do
  task global_values_check: :environment do
    # columns_to_check = %w(comments confirmed_by_whom data_status data_provenance entered_by_whom date_entered data_owned_by)
    columns_to_check = %w(description)

    columns_to_check.each do |column|
      puts "- Global values check for column #{column}."
      tables_with_column(column).each do |table|
        result = simple_query("select distinct(#{column}) from #{table}")
        if result.size < 5  # simple heuristics for 'litter' columns detection
          puts "   * Table #{table}: #{result}."
        end
      end
    end
  end
end
