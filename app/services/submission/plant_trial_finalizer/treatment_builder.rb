class Submission::PlantTrialFinalizer::TreatmentBuilder
  def initialize(submission, plant_trial)
    @submission = submission
    @plant_trial = plant_trial
  end

  def call
    PlantTrial::Treatment.treatment_types.
      select { |property| treatment_content.key?(property.to_s) }.
      each { |property| build_treatment_application(property) }

    treatment
  end

  private

  attr_reader :submission, :plant_trial

  def treatment
    @treatment ||= plant_trial.treatment || plant_trial.build_treatment
  end

  def treatment_content
    submission.content.treatment
  end

  def build_treatment_application(property)
    values = treatment_content.fetch(property.to_s)
    values.each do |name, description|
      treatment_application = treatment.send(property).build(description: description)
      treatment_application.treatment_type = find_or_build_treatment_type(treatment_application, name)
    end
  end

  def find_or_build_treatment_type(treatment_application, treatment_type_name)
    treatment_application.class.treatment_types.find_by(name: treatment_type_name) || begin
      parent_type = PlantTreatmentType.find_by!(term: treatment_application.class.root_term)
      PlantTreatmentType.new(canonical: false, name: treatment_type_name, parent_ids: [parent_type.id])
    end
  end
end
