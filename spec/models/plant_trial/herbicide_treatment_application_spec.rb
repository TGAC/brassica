require "rails_helper"

RSpec.describe PlantTrial::HerbicideTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::HERBICIDE_ROOT_TERM
end
