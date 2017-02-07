require "csv"

class Analysis::Gwas::GenotypeCsvParser
  def call(io)
    Result.new(CSV.new(io)).tap do |result|
      unless result.headers.include?("ID")
        result.errors.add(:base, :no_id_column)
      end

      unless (result.headers - %w(ID)).size > 0
        result.errors.add(:base, :no_mutation_columns)
      end

      unless sample_ids.count > 0
        result.errors.add(:base, :no_samples)
      end
    end
  end

  class Result
    extend ActiveModel::Naming
    extend ActiveModel::Translation

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

    def sample_ids
      id_col_idx = headers.index("ID")

      @sample_ids ||= csv.each.map { |row| row[id_col_idx] }
    end
  end
end
