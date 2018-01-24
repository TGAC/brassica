require "rails_helper"

RSpec.describe PlantTrial::PhTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::PH_ROOT_TERM
end
