require "rails_helper"

RSpec.describe PlantTrial::WaterTemperatureTreatmentApplication do
  it_behaves_like "PlantTrial::TreatmentApplication", PlantTreatmentType::WATER_TEMPERATURE_ROOT_TERM
end
