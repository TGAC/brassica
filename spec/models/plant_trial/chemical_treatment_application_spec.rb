require "rails_helper"

RSpec.describe PlantTrial::ChemicalTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::CHEMICAL_ROOT_TERM
end
