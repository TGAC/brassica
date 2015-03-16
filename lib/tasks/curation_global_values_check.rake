namespace :curate do
  task global_values_check: :environment do
    column = 'data_status'

    tables = tables_with_column(column)

    tables.each do |table|
      result = simple_query("select distinct(#{column}) from #{table}")
      puts "For table #{table}: #{result}"
    end
  end
end
