require "rails_helper"

RSpec.describe PlantTrial::OtherTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::OTHER_ROOT_TERM
end
