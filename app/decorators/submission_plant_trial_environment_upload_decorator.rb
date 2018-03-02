class SubmissionPlantTrialEnvironmentUploadDecorator < SubmissionUploadDecorator
  def as_json(*)
    super.merge(
      summary: (parser_summary unless new_record?)
    )
  end

  def parser_summary
    environment = submission.content.environment

    return [] unless environment

    [].tap do |summary|
      PlantTrial::Environment.measured_properties.keys.map(&:to_s).
        select { |property| environment.key?(property) }.
        each do |property|
          unit_name, value = environment.fetch(property)
          label = Submission::PlantTrialEnvironmentParser.environment_labels.fetch(property.to_sym)
          summary << "#{label}: #{value} #{unit_name}"
        end

      (PlantTrial::Environment.dictionary_properties + [:ph]).map(&:to_s).
        select { |property| environment.key?(property) }.
        each do |property|
          values = environment.fetch(property)
          label = Submission::PlantTrialEnvironmentParser.environment_labels.fetch(property.to_sym)

          summary << "#{label}:\n#{values.map { |v| " - #{v.join("; ")}" }.join("\n")}"
        end

      ["co2_controlled"].select { |property| environment.key?(property) }.each do |property|
        value = environment.fetch(property)
        label = Submission::PlantTrialEnvironmentParser.environment_labels.fetch(property.to_sym)
        summary << "#{label}: #{value}"
      end
    end
  end
end
