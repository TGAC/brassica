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
          return if header.lines.empty?
          @sample_ids ||= header.samples
        end

        def each_record(&blk)
          io.each_line do |line|
            fields = BioVcf::VcfLine.parse(line)

            yield BioVcf::VcfRecord.new(fields, header)
          end
        end
      end
    end
  end
end
