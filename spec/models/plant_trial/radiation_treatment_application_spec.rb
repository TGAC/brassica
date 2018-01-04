require "rails_helper"

RSpec.describe PlantTrial::RadiationTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::RADIATION_ROOT_TERM
end
