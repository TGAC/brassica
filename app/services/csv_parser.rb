require "csv"

class CsvParser
  def call(io, result_class = Result)
    result_class.new(CSV.new(io))

  rescue CSV::MalformedCSVError => ex
    result_class.new(CSV.new(StringIO.new)).tap do |result|
      # TODO: expose detailed info (e.g. Illegal quoting in line 2)
      result.errors << :malformed_csv
    end
  end

  class Result
    attr_reader :errors, :csv, :headers

    def initialize(csv)
      @csv = csv
      @headers = csv.readline || []
      @errors = []
    end

    def valid?
      errors.empty?
    end

    def rewind(skip_header: true)
      csv.rewind
      csv.readline if skip_header
      csv.pos
    end
  end
end
