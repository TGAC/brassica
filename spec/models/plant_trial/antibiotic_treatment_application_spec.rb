require "rails_helper"

RSpec.describe PlantTrial::AntibioticTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::ANTIBIOTIC_ROOT_TERM
end
