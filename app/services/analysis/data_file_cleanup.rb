class Analysis
  class DataFileCleanup
    def call
      Analysis::DataFile.input.
        where(analysis_id: nil).
        where("created_at < ?", 1.week.ago).
        destroy_all
    end
  end
end
