class Analysis
  # Copies given CSV file intended to be used as GWASSER input doing some of the following:
  #
  # * replace non-alphanumeric characters in row and column headers with underscores
  # * remove specified columns
  # * remove specified rows
  class CsvNormalizer
    def call(file, normalize_first_column: false, normalize_first_row: false, remove_columns: [], remove_rows: [])
      rows_retained = 0
      normalized_csv = CSV.generate(force_quotes: true) do |csv|
        CSV.open(file.path, "r") do |existing_csv|
          headers = existing_csv.readline

          return :all_columns_removed if headers.size - remove_columns.size < 2

          remove_col_idxes = remove_columns.map { |col| headers.index(col) }

          existing_csv.rewind
          existing_csv.each.with_index do |row, row_idx|
            next if remove_rows.include?(row[0])

            csv << row.map.with_index do |val, col_idx|
              next if remove_col_idxes.include?(col_idx)

              normalize_value = (row_idx == 0 && normalize_first_row) || (col_idx == 0 && normalize_first_column)

              if normalize_value
                # TODO: make sure normalized names are unique
                val.strip.gsub(/\W+/, '_')
              else
                val.strip
              end
            end.compact

            rows_retained += 1
          end
        end
      end

      return :all_rows_removed if rows_retained < 2

      tmpfile = create_tmpfile(file.original_filename, normalized_csv)

      [:ok, tmpfile]
    end

    private

    def create_tmpfile(original_filename, normalized_csv)
      NamedTempfile.new(".csv").tap do |tmpfile|
        tmpfile.original_filename = "#{File.basename(original_filename, ".csv")}.normalized.csv"
        tmpfile << normalized_csv
        tmpfile.flush
        tmpfile.rewind
      end
    end
  end
end
