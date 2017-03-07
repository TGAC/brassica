require "csv"

class Analysis
  class Gwas
    class MapCsvParser
      def call(io)
        Analysis::CsvParser.new.call(io, Result).tap do |result|
          result.errors << :no_id_column unless result.headers.include?("ID")
          result.errors << :no_chr_column unless result.headers.include?("Chr")
          result.errors << :no_cm_column unless result.headers.include?("cM")
          result.errors << :no_mutations if result.mutation_ids.blank?

          result.rewind
        end
      end

      class Result < Analysis::CsvParser::Result
        def mutation_ids
          id_col_idx = headers.index("ID")

          return unless id_col_idx

          @mutation_ids ||= csv.each.map { |row| row[id_col_idx] }
        end
      end
    end
  end
end
