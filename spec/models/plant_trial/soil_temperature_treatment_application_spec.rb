require "rails_helper"

RSpec.describe PlantTrial::SoilTemperatureTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::SOIL_TEMPERATURE_ROOT_TERM
end
