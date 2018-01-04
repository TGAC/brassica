require "rails_helper"

RSpec.describe PlantTrial::BioticTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::BIOTIC_ROOT_TERM
end
