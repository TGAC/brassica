require "rails_helper"

RSpec.describe PlantTrial::HumidityTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::HUMIDITY_ROOT_TERM
end
