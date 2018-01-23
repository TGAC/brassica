require "bio-vcf"

class Analysis
  class Gwas
    class GenotypeVcfParser
      def call(io)
        header = parse(io)

        Result.new(header, io).tap do |result|
          if header.lines.empty?
            result.errors << :not_a_vcf
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

      def parse(io)
        io_pos = io.pos
        header = BioVcf::VcfHeader.new
        line = io.readline

        return header unless line =~ /^##fileformat=/

        header.add(line)

        io.each_line do |headerline|
          # Detect end of header
          if headerline !~ /^#/
            io.seek(io_pos)
            break
          end
          header.add(headerline)

          io_pos = io.pos
        end

        header

      rescue EOFError
        header
      end

      class Result
        attr_accessor :header
        attr_reader :errors, :io

        def initialize(header, io)
          @header = header
          @io = io
          @errors = []
        end

        def valid?
          errors.empty?
        end

        def sample_ids
          return [] if header.lines.empty?
          @sample_ids ||= header.samples
        end

        def each_record(&blk)
          enum = io.each_line.lazy.map do |line|
            fields = ensure_id(BioVcf::VcfLine.parse(line))
            BioVcf::VcfRecord.new(fields, header)
          end

          block_given? ? enum.each(&blk) : enum
        end

        private

        # Make sure record has a unique identifier
        def ensure_id(fields)
          id_idx = 2
          chrom_idx = 0
          pos_idx = 1

          return fields unless fields[id_idx] == "."

          fields[id_idx] = fields.values_at(chrom_idx, pos_idx).map(&:to_s).join(".")
          fields
        end
      end
    end
  end
end
