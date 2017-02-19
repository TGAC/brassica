require "csv"

class Analysis
  class Gwas
    class GenotypeCsvParser
      def call(io)
        Result.new(CSV.new(io)).tap do |result|
          unless result.headers.include?("ID")
            result.errors << :no_id_column
          end

          if result.mutation_ids.blank?
            result.errors << :no_mutations
          end

          if result.sample_ids.blank?
            result.errors << :no_samples
          end
        end

      # TODO: handle empty file

      rescue CSV::MalformedCSVError => ex
        Result.new(CSV.new(StringIO.new)).tap do |result|
          # TODO: expose detailed info (e.g. Illegal quoting in line 2)
          result.errors << :malformed_csv
        end
      end

      class Result
        attr_reader :errors, :csv

        def initialize(csv)
          @csv = csv
          @errors = []
        end

        def valid?
          errors.empty?
        end

        def headers
          @headers ||= csv.readline
        end

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
