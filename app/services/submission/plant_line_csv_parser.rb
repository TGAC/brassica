class Submission::PlantLineCsvParser
  def call(io)
    CsvParser.new.call(io, Result).tap do |result|
      check_errors(result)
    end
  end

  private

  def check_errors(parser_result)
    if parser_result.headers.blank?
      parser_result.errors << :no_header_plant_lines
    else
      header_columns.each do |column_name|
        if parser_result.headers.index(column_name).nil?
          parser_result.errors << :"no_#{column_name.downcase.parameterize('_')}_header"
        end
      end
    end
  rescue CSV::MalformedCSVError
    parser_result.errors << :malformed_csv
  ensure
    parser_result.rewind
  end

  private

  def header_columns
    [
      "Species",
      "Plant variety",
      "Crop type",
      "Plant line",
      "Common name",
      "Previous line name",
      "Genetic status",
      "Sequence",
      "Plant accession",
      "Originating organisation",
      "Year produced"
    ]
  end

  class Result < CsvParser::Result
    def each(&blk)
      csv.each { |row| blk.call(parse_row(row)) }
    end

    private

    def parse_row(row)
      row.map { |d| d.nil? ? '' : d.strip }
    end
  end
end
