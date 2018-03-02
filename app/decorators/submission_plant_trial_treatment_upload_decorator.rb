class SubmissionPlantTrialTreatmentUploadDecorator < SubmissionUploadDecorator
  def as_json(*)
    super.merge(
      summary: (parser_summary unless new_record?)
    )
  end

  def parser_summary
    treatment = submission.content.treatment

    return [] unless treatment

    [].tap do |summary|
      PlantTrial::Treatment.treatment_types.map(&:to_s).
        select { |property| treatment.key?(property) }.
        each do |property|
          values = treatment.fetch(property)
          label = Submission::PlantTrialTreatmentParser.treatment_labels.fetch(property.to_sym)

          summary << "#{label}:\n#{values.map { |v| " - #{v.join("; ")}" }.join("\n")}"
        end
    end
  end
end
