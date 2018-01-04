require "rails_helper"

RSpec.describe PlantTrial::PesticideTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::PESTICIDE_ROOT_TERM
end
