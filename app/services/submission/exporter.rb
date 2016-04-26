class Submission::Exporter
  def initialize(submission)
    @submission = submission
  end

  def documents
    raise NotImplemented, "Must be implemented by subclasses"
  end

  private

  def submitted_object
    @submission.submitted_object
  end

  def generate_document(klass, query)
    data = klass.table_data(query: query).
                 map{ |r| r[0, klass.table_columns.size] }
    return nil if data.empty?
    CSV.generate(headers: true) do |csv|
      csv << humanize_columns(klass.table_columns)
      data.each { |row| csv << row }
    end
  end

  def humanize_columns(column_names)
    column_names.map do |column_name|
      column_name.split(/ as /i)[-1]
    end
  end
end
