class Submission::PlantTrialTreatmentProcessor
  def initialize(upload, parser = Submission::PlantTrialTreatmentParser.new)
    @upload = upload
    @parser = parser
  end

  def call
    parser_result = @parser.call(@upload.file.path)

    unless parser_result.valid?
      parser_result.errors.each { |error| @upload.errors.add(:file, *error) }
      return
    end

    treatment = process_treatment(parser_result.treatment)
    update_submission_content(treatment) if @upload.errors.empty?
  end

  private

  def process_treatment(treatment)
    {}.tap do |result|
      PlantTrial::Treatment.treatment_types.
        select { |property| treatment.key?(property) }.
        map { |property| process_dictionary_property(treatment, property) }.
        compact.uniq.
        each { |property, label, values| result[property] = values }

      @upload.errors.add(:file, :treatment_data_empty) if result.empty? && @upload.errors.empty?
    end
  end

  def update_submission_content(treatment)
    @upload.submission.content.update(:step06, treatment: treatment)
    @upload.submission.save!
  end

  def process_dictionary_property(data, property)
    label, values = data.fetch(property)

    if values.any? { |term, _description| term.blank? }
      @upload.errors.add(:file, :treatment_term_missing, treatment: label)
      return
    end

    [property, label, values.map(&:compact)]
  end
end
