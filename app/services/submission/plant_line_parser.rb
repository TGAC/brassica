class Submission::PlantLineParser
  def call(filename)
    xls = Roo::Excel.new(filename)

    errors = check_errors(xls)
    rows = errors.blank? ? parse_data(xls) : {}

    Result.new(errors, rows)

  rescue Ole::Storage::FormatError => ex
    Rails.logger.warn("#{ex}\n#{ex.backtrace.join("\n")}")
    Result.new([[:plant_lines_parsing_error, error: ex.message]], [])
  end

  private

  def check_errors(xls)
    return [:no_plant_lines_sheet] unless xls.sheets.include?("Plant lines")
    return [:invalid_plant_lines_header] unless valid_first_column?(xls)

    header_columns.each.with_index.select do |column_name, idx|
      # NOTE: +1 for first column
      xls.row(1, "Plant lines")[idx + 1].blank?
    end.map do |column_name, _|
      :"no_#{column_name.downcase.parameterize(separator: '_')}_header"
    end
  end

  def valid_first_column?(xls)
    %w(Column Description Requirements) == (1..3).map { |row_idx| xls.cell(row_idx, 1, "Plant lines") }
  end

  def parse_data(xls)
    (4..xls.last_row).map { |row_idx| parse_row(xls.row(row_idx, "Plant lines")) }
  end

  def parse_row(row)
    row = row.map { |d| d && d.is_a?(String) ? d.strip : d }

    [
      { plant_variety_name: row[2], crop_type: row[3] }.compact,
      { plant_line_name: row[4], common_name: row[5], previous_line_name: row[6],
        genetic_status: row[7], sequence_identifier: row[8], taxonomy_term: row[1] }.compact,
      { plant_accession: row[9], originating_organisation: row[10],
        year_produced: row[11].try(:to_i).try(:to_s) }.compact
    ]
  end

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

  class Result
    attr_reader :errors, :rows

    def initialize(errors, rows)
      @errors = errors || []
      @rows = rows || []
    end

    def valid?
      errors.empty?
    end
  end
end
