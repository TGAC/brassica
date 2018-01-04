require "rails_helper"

RSpec.describe PlantTrial::FertilizerTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::FERTILIZER_ROOT_TERM
end
