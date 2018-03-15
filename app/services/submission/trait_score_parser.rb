class Submission::TraitScoreParser
  def call(filename)
    xls = Roo::Excel.new(filename)

    errors = check_errors(xls)
    columns, rows = errors.blank? ? parse_data(xls) : {}

    Result.new(errors, columns, rows)

  rescue Ole::Storage::FormatError => ex
    Rails.logger.warn("#{ex}\n#{ex.backtrace.join("\n")}")
    Result.new([[:trait_scores_parsing_error, error: ex.message]], [], [])
  end

  private

  def check_errors(xls)
    return [:no_trait_scores_sheet] unless xls.sheets.include?("Trait scores")
    return [:invalid_trait_scores_header] unless valid_first_column?(xls)

    [].tap do |errors|
      header = xls.row(1, "Trait scores")

      unless header.include?('Plant line') || header.include?('Plant variety')
        errors << :no_line_or_variety_header
      end

      required_header_columns.
        reject { |column_name| header.include?(column_name) }.
        each do |column_name|
          errors << :"no_#{column_name.downcase.parameterize(separator: '_')}_header"
        end
    end
  end

  def valid_first_column?(xls)
    %w(Column Description) == (1..2).map { |row_idx| xls.cell(row_idx, 1, "Trait scores") }
  end

  def required_header_columns
    [
      "Plant scoring unit name",
      "Plant accession",
      "Originating organisation",
      "Year produced"
    ]
  end

  def parse_data(xls)
    columns = xls.row(1, "Trait scores")[1..-1]
    year_produced_idx ||= columns.index("Year produced") + 1

    rows = (3..xls.last_row).
      map do |row_idx|
        row = xls.row(row_idx, "Trait scores")
        year_produced = row[year_produced_idx]

        row[year_produced_idx] = year_produced.to_i.to_s if year_produced && !year_produced.is_a?(String)
        row[1..-1]
      end.
      select { |row| row.any?(&:present?) }

    [columns, rows]
  end

  class Result
    attr_reader :errors, :columns, :rows

    def initialize(errors, columns, rows)
      @errors = errors || []
      @columns = columns || []
      @rows = rows || []
    end

    def valid?
      errors.empty?
    end
  end
end
