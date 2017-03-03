require "csv"

class Analysis
  class Gwas
    class GenotypeCsvParser
      def call(io)
        Analysis::CsvParser.new.call(io, Result).tap do |result|
          unless result.headers.include?("ID")
            result.errors << :no_id_column
          end

          if result.mutation_ids.blank?
            result.errors << :no_mutations
          end

          if result.sample_ids.blank?
            result.errors << :no_samples
          end

          result.rewind
        end
      end

      class Result < Analysis::CsvParser::Result
        def mutation_ids
          headers - %w(ID)
        end

        def sample_ids
          id_col_idx = headers.index("ID")

          return unless id_col_idx

          @sample_ids ||= csv.each.map { |row| row[id_col_idx] }
        end
      end
    end
  end
end
