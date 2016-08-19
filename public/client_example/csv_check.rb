require 'csv'

# Try to detect non UTF-8 encoded CSV data file.

if ARGV.size < 1
  STDERR.puts <<-USAGE
Not enough arguments.
Usage:

> ruby csv_check.rb input_file.csv

  USAGE
  exit 1
end

def check_csv(filename)
  CSV.read(filename, encoding: "UTF-8")
  :ok
rescue ArgumentError => ex
  if ex.message == "invalid byte sequence in UTF-8"
    return :invalid
  else
    return :failure
  end
rescue => ex
  return :failure
end

filename = ARGV[0]

case check_csv(filename)
when :ok
  puts "File correctly encoded as UTF-8."
when :invalid
  puts "Not a UTF-8 encoded CSV file."
when :failure
  puts "Could not detect encoding of #{filename}."
end
