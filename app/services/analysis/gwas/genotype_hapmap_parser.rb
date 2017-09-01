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
          records = io.each_line.lazy.map { |line| Record.new(sample_ids, line.split(/\s+/)) }

          block_given? ? records.each(&blk) : records
        end
      end

      class Record
        attr_reader :sample_ids

        def initialize(sample_ids, raw)
          @sample_ids = sample_ids
          @raw = raw
        end

        def rs
          rs_idx = HEADER_COLUMNS.index("rs#")

          if @raw[rs_idx].blank?
            @raw[id_idx] = [chrom, pos].map(&:to_s).join(".")
          end

          @raw[rs_idx]
        end

        def alleles
          @raw[HEADER_COLUMNS.index("alleles")]
        end

        def chrom
          @raw[HEADER_COLUMNS.index("chrom")]
        end

        def pos
          @raw[HEADER_COLUMNS.index("pos")]
        end

        def samples
          @raw[HEADER_COLUMNS.size..-1]
        end
      end
    end
  end
end
