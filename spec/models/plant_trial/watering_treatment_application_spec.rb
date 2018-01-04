require "rails_helper"

RSpec.describe PlantTrial::WateringTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::WATERING_ROOT_TERM
end
