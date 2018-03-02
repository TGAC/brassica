class Submission::PlantTrialEnvironmentProcessor
  def initialize(upload, parser = Submission::PlantTrialEnvironmentParser.new)
    @upload = upload
    @parser = parser
  end

  def call
    parser_result = @parser.call(@upload.file.path)

    unless parser_result.valid?
      parser_result.errors.each { |error| @upload.errors.add(:file, *error) }
      return
    end

    environment = process_environment(parser_result.environment)
    update_submission_content(environment) if @upload.errors.empty?
  end

  private

  def process_environment(environment)
    {}.tap do |result|
      PlantTrial::Environment.measured_properties.
        select { |property, _| environment.key?(property) }.
        map { |property, constraints| process_measured_property(environment, property, constraints) }.
        compact.uniq.
        each { |property, label, unit_name, value| result[property] = [unit_name, value] }

      (PlantTrial::Environment.dictionary_properties + [:ph]).
        select { |property| environment.key?(property) }.
        map { |property| process_dictionary_property(environment, property) }.
        compact.uniq.
        each { |property, label, values| result[property] = values }

      [:co2_controlled].
        select { |property| environment.key?(property) }.
        map { |property| process_enum_property(environment, property) }.
        compact.uniq.
        each { |property, label, value| result[property] = value }

      @upload.errors.add(:file, :environment_data_empty) if result.empty? && @upload.errors.empty?
    end
  end

  def update_submission_content(environment)
    @upload.submission.content.update(:step05, environment: environment)
    @upload.submission.save!
  end

  def process_measured_property(data, property, constraints)
    label, values = data.fetch(property)

    if values.size > 1
      @upload.errors.add(:file, :multiple_values, property: label)
      return
    end

    unit_name, value = values.first

    return if value.blank?

    unless unit = MeasurementUnit.find_by(name: unit_name)
      @upload.errors.add(:file, :invalid_unit, unit: unit_name, property: label)
      return
    end

    measurement_value = PlantTrial::MeasurementValue.new(property: property,
                                                         unit: unit,
                                                         value: value,
                                                         constraints: constraints)
    measurement_value.validate

    if measurement_value.errors[:value].present?
      cause = measurement_value.errors.full_messages_for(:value).join(". ").concat(".")
      @upload.errors.add(:file, :invalid_value, property: label, value: value, cause: cause)
      return
    end

    if measurement_value.errors[:property].present?
      errors = measurement_value.errors.full_messages_for(:property).join(". ").concat(".")
      fail "Unexpected error on property field: #{errors}"
    end

    [property, label, unit_name, value]
  end

  def process_dictionary_property(data, property)
    label, values = data.fetch(property)

    if values.any? { |term, _description| term.blank? }
      @upload.errors.add(:file, :environment_term_missing, property: label)
      return
    end

    if :topological_descriptors == property
      if values.any? { |_term, description| description.blank? }
        @upload.errors.add(:file, :description_missing, property: label)
        return
      end
    end

    [property, label, values.map(&:compact)]
  end

  def process_enum_property(data, property)
    label, values = data.fetch(property)

    if values.size > 1
      @upload.errors.add(:file, :multiple_values, property: label)
      return
    end

    [property, label, values.flatten.first]
  end
end
