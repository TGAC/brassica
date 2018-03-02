require "rails_helper"

RSpec.describe PlantTrial::SoilTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::SOIL_ROOT_TERM
end
