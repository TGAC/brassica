class Analysis
  class Gwas
    class CsvNormalizer
      def call(file, remove_columns: [], remove_rows: [])
        normalized_csv = CSV.generate(force_quotes: true) do |csv|
          CSV.open(file.path, "r") do |existing_csv|
            headers = existing_csv.readline

            if headers.size - remove_columns.size < 2
              return :all_but_one_columns_removed
            end

            remove_col_idxes = remove_columns.map { |col| headers.index(col) }

            existing_csv.rewind
            existing_csv.each.with_index do |row, row_idx|
              next if remove_rows.include?(row[0])

              csv << row.map.with_index do |val, col_idx|
                next if remove_col_idxes.include?(col_idx)

                if row_idx == 0 || col_idx == 0
                  # TODO: make sure normalized names are unique
                  val.strip.gsub(/\W+/, '_')
                else
                  val.strip
                end
              end.compact
            end
          end
        end

        file = Tempfile.new([File.basename(file.path, ".csv") + "-normalized", ".csv"])
        file << normalized_csv
        file.flush
        file.rewind

        [:ok, file]
      end
    end
  end
end
