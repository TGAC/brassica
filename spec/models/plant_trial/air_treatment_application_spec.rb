require "rails_helper"

RSpec.describe PlantTrial::AirTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::AIR_ROOT_TERM
end
