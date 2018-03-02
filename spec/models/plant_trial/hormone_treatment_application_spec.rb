require "rails_helper"

RSpec.describe PlantTrial::HormoneTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::HORMONE_ROOT_TERM
end
