require "rails_helper"

RSpec.describe PlantTrial::MechanicalTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::MECHANICAL_ROOT_TERM
end
