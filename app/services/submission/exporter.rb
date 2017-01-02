class Submission::Exporter
  def initialize(submission)
    @submission = submission
  end

  def documents
    raise NotImplementedError, "Must be implemented by subclasses"
  end

  private

  def submitted_object
    @submission.submitted_object
  end

  def generate_document(klass, query, column_names: nil)
    column_names ||= klass.table_columns
    data = klass.table_data(query: query).
                 map{ |r| r[0, column_names.size] }
    return nil if data.empty?
    CSV.generate(headers: true) do |csv|
      csv << humanize_columns(klass, column_names)
      data.each { |row| csv << row }
    end
  end

  def humanize_columns(klass, column_names)
    column_names.map do |column_name|
      column_name = column_name.split(/ as /i)[-1]
      column_name = "#{klass.table_name}.#{column_name}" unless column_name.include? '.'
      I18n.t("tables.#{column_name}")
    end
  end
end
