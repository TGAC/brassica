require "rails_helper"

RSpec.describe PlantTrial::SeasonalTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::SEASONAL_ROOT_TERM
end
