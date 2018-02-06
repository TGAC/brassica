class Submission::PlantTrialFinalizer::EnvironmentBuilder
  def initialize(submission, plant_trial)
    @submission = submission
    @plant_trial = plant_trial
  end

  def call
    PlantTrial::Environment.measured_properties.keys.
      select { |property| environment_content.key?(property.to_s) }.
      each { |property| build_measurement_value(property) }

    PlantTrial::Environment.dictionary_properties.
      select { |property| environment_content.key?(property.to_s) }.
      each { |property| build_associated_objects(property) }

    environment.co2_controlled = environment_content["co2_controlled"]

    environment
  end


  private

  attr_reader :submission, :plant_trial

  def environment
    @environment ||= plant_trial.environment || plant_trial.build_environment
  end

  def environment_content
    submission.content.environment
  end

  def build_measurement_value(property)
    unit_name, value = environment_content.fetch(property.to_s)
    unit = MeasurementUnit.find_by!(name: unit_name)

    environment.measurement_values.build(property: property, unit: unit, value: value, context: environment)
  end

  def build_associated_objects(property)
    values = environment_content.fetch(property.to_s)

    values.each do |name, description|
      case property
      when :lamps
        type = find_or_build_dictionary_object(LampType, name)
        environment.lamps.build(lamp_type: type, description: description)
      when :containers
        type = find_or_build_dictionary_object(ContainerType, name)
        environment.containers.build(container_type: type, description: description)
      when :topological_descriptors
        factor = find_or_build_dictionary_object(TopologicalFactor, name)
        environment.topological_descriptors.build(topological_factor: factor, description: description)
      when :rooting_media
        type = find_or_build_treatment_type(PlantTrial::RootingMedium, name)
        environment.rooting_media.build(medium_type: type, description: description)
      end
    end
  end

  def find_or_build_dictionary_object(klass, name)
    klass.find_by(name: name) || klass.new(canonical: false, name: name)
  end

  def find_or_build_treatment_type(context_klass, name)
    PlantTreatmentType.descendants_of(context_klass.root_term).find_by(name: [name, "#{name} treatment"]) || begin
      parent_type = PlantTreatmentType.find_by!(term: context_klass.root_term)
      PlantTreatmentType.new(canonical: false, name: name, parent_ids: [parent_type.id])
    end
  end
end
