class PlantTrialDecorator < Draper::Decorator
  delegate_all

  # Provides list of trait names scored in this trial.
  # Also includes technical replicates, if present.
  def trait_headers
    trait_descriptors.map do |td|
      (1..replicate_numbers[td.id]).map do |replicate_number|
        if replicate_number == 1 && replicate_numbers[td.id] == 1
          td.trait_name
        else
          "#{td.trait_name} rep#{replicate_number}"
        end
      end
    end.flatten
  end
end
