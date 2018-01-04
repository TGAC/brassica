class PlantTrial::HumidityTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::HUMIDITY_ROOT_TERM
  end
end
