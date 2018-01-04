require "rails_helper"

RSpec.describe PlantTrial::FungicideTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::FUNGICIDE_ROOT_TERM
end
