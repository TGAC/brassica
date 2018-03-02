class PlantTrial::WateringTreatmentApplication < PlantTrial::TreatmentApplication
  def self.root_term
    PlantTreatmentType::WATERING_ROOT_TERM
  end
end
