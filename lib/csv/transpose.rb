require "csv"

class CSV::Transpose
  def initialize(path)
    @path = path
  end

  def call(csv_options = {})
    input = CSV.read(@path, csv_options)
    input_row_length = input[0].size

    output = CSV.generate(csv_options) do |csv|
      (0...input_row_length).each do |col_idx|
        csv << input.map { |row| row[col_idx] }
      end
    end

    Tempfile.open("") do |tmpfile|
      tmpfile << output
      tmpfile.flush

      FileUtils.cp tmpfile.path, @path
    end
  end
end
