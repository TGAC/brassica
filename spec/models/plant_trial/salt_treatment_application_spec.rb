require "rails_helper"

RSpec.describe PlantTrial::SaltTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::SALT_ROOT_TERM
end
