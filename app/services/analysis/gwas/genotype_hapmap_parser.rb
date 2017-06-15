class Analysis
  class Gwas
    class GenotypeHapmapParser
      HEADER_COLUMNS = %w(rs# alleles chrom pos strand assembly# center protLSID assayLSID panelLSID QCcode)

      def call(io)
        Result.new(io).tap do |result|
          if result.columns[0...HEADER_COLUMNS.size] != HEADER_COLUMNS
            result.errors << :not_a_hapmap
          end

          if result.sample_ids.blank?
            result.errors << :no_samples
          end

          if io.eof?
            result.errors << :no_mutations
          end
        end
      end

      private

      class Result
        attr_accessor :columns
        attr_reader :errors, :io

        def initialize(io)
          @io = io
          @errors = []
          @columns = io.readline.split(/\s+/)
        rescue EOFError
          @columns = []
        end

        def valid?
          errors.empty?
        end

        def sample_ids
          @sample_ids ||= columns[HEADER_COLUMNS.size..-1]
        end

        def each_record(&blk)
          enum = io.each_line.lazy.map do |line|
            ensure_id(line.split(/\s+/))
          end

          block_given? ? enum.each(&blk) : enum
        end

        private

        # Make sure record has a unique identifier
        def ensure_id(fields)
          id_idx = HEADER_COLUMNS.index("rs#")
          chrom_idx = HEADER_COLUMNS.index("chrom")
          pos_idx = HEADER_COLUMNS.index("pos")

          return fields unless fields[id_idx].blank?

          fields[id_idx] = fields.values_at(chrom_idx, pos_idx).map(&:to_s).join(".")
          fields
        end
      end
    end
  end
end
