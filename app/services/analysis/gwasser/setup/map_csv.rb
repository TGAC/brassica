class Analysis
  class Gwasser
    class Setup
      class MapCsv
        include Helpers

        def initialize(analysis)
          @analysis = analysis
        end

        def applicable?
          map_data_file.try(:uploaded?)
        end

        def call
          map_status, map_csv_file = normalize_map_csv

          check_map_status(map_status).tap do |status|
            create_csv_data_file(map_csv_file, data_type: :gwas_map) if status == :ok
          end
        end

        private

        attr_accessor :analysis

        def normalize_map_csv
          normalize_csv(map_data_file.file, remove_rows: analysis.meta['removed_mutations'])
        end

        def check_map_status(status)
          case status
          when :ok then :ok
          else fail "Invalid status: #{status}"
          end
        end
      end
    end
  end
end
