require "rails_helper"

RSpec.describe PlantTrial::RainfallTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::RAINFALL_ROOT_TERM
end
