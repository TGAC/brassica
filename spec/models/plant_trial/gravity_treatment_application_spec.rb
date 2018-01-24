require "rails_helper"

RSpec.describe PlantTrial::GravityTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::GRAVITY_ROOT_TERM
end
